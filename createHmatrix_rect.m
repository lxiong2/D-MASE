function H = createHmatrix_rect(e,f,G,B,numtype,indices,numbus,buses,lines,paraLineIndex,adjbuses)

% Initialize
pfindices = indices(1:numtype(1),:);
qfindices = indices(numtype(1)+(1:numtype(2)),:);
pindices = indices(numtype(1)+numtype(2)+(1:numtype(3)),:);
qindices = indices(numtype(1)+numtype(2)+numtype(3)+(1:numtype(4)),:);
vindices = indices(numtype(1)+numtype(2)+numtype(3)+numtype(4)+(1:numtype(5)),:);

%% Real power flow measurements [dPijdth dPijdV]
% Hpf = zeros(numtype(1),numbus*2);
% for a = 1:numtype(1)
%     indPFmeas = pfindices(a,:);
%     [dPijde, dPijdf] = realPowerFlowMeas_rect(e,f,G,B,buses,lines,indPFmeas);
%     Hpf(a,:) = [dPijde dPijdf];
% end
Hpf1 = zeros(numtype(1),numbus); % dPij/de
Hpf2 = zeros(numtype(1),numbus); % dPij/df
pfm = pfindices(:,1);
pfn = pfindices(:,2);
% for single branches
pftempVec = sub2ind([numbus numbus],pfm,pfn); % get G(m,n) in a vectorized way
pfG = G(pftempVec);
pfB = B(pftempVec);
indpfm = sub2ind([numtype(1) numbus],(1:numtype(1)).',pfm);
indpfn = sub2ind([numtype(1) numbus],(1:numtype(1)).',pfn);
Hpf1(indpfm) = -2*pfG.*e(pfm)+pfG.*e(pfn)-pfB.*f(pfn);
Hpf1(indpfn) = pfG.*e(pfm)+pfB.*f(pfm);
Hpf2(indpfm) = -2*pfG.*f(pfm)+pfG.*f(pfn)+pfB.*e(pfn);
Hpf2(indpfn) = pfG.*f(pfm)-pfB.*e(pfm);
% for parallel branches
Yeq = 1./(lines(paraLineIndex,4)+1i*lines(paraLineIndex,5));
lilg = real(Yeq);
lilb = imag(Yeq);
pfm2 = pfindices(paraLineIndex,1);
pfn2 = pfindices(paraLineIndex,2);
indpfm2 = sub2ind([numtype(1) numbus],paraLineIndex,pfm2);
indpfn2 = sub2ind([numtype(1) numbus],paraLineIndex,pfn2);
Hpf1(indpfm2) = 2*lilg.*e(pfm2)-lilg.*e(pfn2)+lilb.*f(pfn2);
Hpf1(indpfn2) = -lilg.*e(pfm2)-lilb.*f(pfm2);
Hpf2(indpfm2) = 2*lilg.*f(pfm2)-lilg.*f(pfn2)-lilb.*e(pfn2);
Hpf2(indpfn2) = -lilg.*f(pfm2)+lilb.*e(pfm2);
Hpf = [Hpf1 Hpf2];

%% Reactive power flow measurements [dQijdth dQijdV]
% Hqf = zeros(numtype(2),numbus*2);
% for a = 1:numtype(2)
%     indQFmeas = qfindices(a,:);
%     [dQijde, dQijdf] = reactivePowerFlowMeas_rect(e,f,G,B,buses,lines,indQFmeas);
%     Hqf(a,:) = [dQijde dQijdf];
% end
Hqf1 = zeros(numtype(2),numbus); % dQij/de
Hqf2 = zeros(numtype(2),numbus); % dQij/df
qfm = qfindices(:,1);
qfn = qfindices(:,2);
% for single branches
qftempVec = sub2ind([numbus numbus],qfm,qfn); % get G(m,n) in a vectorized way
qfG = G(qftempVec);
qfB = B(qftempVec);
indqfm = sub2ind([numtype(2) numbus],(1:numtype(2)).',qfm);
indqfn = sub2ind([numtype(2) numbus],(1:numtype(2)).',qfn);
bsi = lines(:,6)/2; % DEBUG: not generalized
Hqf1(indqfm) = 2*qfB.*e(qfm)-qfB.*e(qfn)-qfG.*f(qfn)-2*e(qfm).*bsi;
Hqf1(indqfn) = -qfB.*e(qfm)+qfG.*f(qfm);
Hqf2(indqfm) = 2*qfB.*f(qfm)-qfB.*f(qfn)+qfG.*e(qfn)-2*f(qfm).*bsi;
Hqf2(indqfn) = -qfB.*f(qfm)-qfG.*e(qfm);
% for parallel branches
Yeq = 1./(lines(paraLineIndex,4)+1i*lines(paraLineIndex,5));
lilg = real(Yeq);
lilb = imag(Yeq);
qfm2 = qfindices(paraLineIndex,1);
qfn2 = qfindices(paraLineIndex,2);
indqfm2 = sub2ind([numtype(2) numbus],paraLineIndex,qfm2);
indqfn2 = sub2ind([numtype(2) numbus],paraLineIndex,qfn2);
Hqf1(indqfm2) = -2*(lilb+bsi(paraLineIndex)).*e(qfm2)+lilb.*e(qfn2)+lilg.*f(qfn2);
Hqf1(indqfn2) = lilb.*e(qfm2)-lilg.*f(qfm2);
Hqf2(indqfm2) = -2*(lilb+bsi(paraLineIndex)).*f(qfm2)+lilb.*f(qfn2)-lilg.*e(qfn2);
Hqf2(indqfn2) = lilb.*f(qfm2)+lilg.*e(qfm2);
Hqf = [Hqf1 Hqf2];

%% Real power injection measurements [dPdth dPdV]
% Hp = zeros(numtype(3),numbus*2);
% for a = 1:numtype(3)
%     indPmeas = pindices(a,:);
%     [dPde, dPdf] = realPowerInjMeas_rect(e,f,G,B,numbus,buses,adjbuses,indPmeas);
%     Hp(a,:) = [dPde dPdf];
% end
pm = pindices(:,1);
ptempVec = sub2ind([numbus numbus],pm,pm); % get G(m,m) in a vectorized way
pG = G(ptempVec);
pB = B(ptempVec);
peMat = zeros(numbus,numbus);
pfMat = zeros(numbus,numbus);

peMat(ptempVec) = e(pm);
pfMat(ptempVec) = f(pm);

Hp1 = peMat*G(pm,:)+pfMat*B(pm,:); % the order of multiplication matters; overwise you get transverse
Hp1(ptempVec) = G(pm,:)*e(pm)-B(pm,:)*f(pm)+pG.*e(pm)+pB.*f(pm);
Hp2 = peMat*-B(pm,:)+pfMat*G(pm,:);
Hp2(ptempVec) = G(pm,:)*f(pm)+B(pm,:)*e(pm)+pG.*f(pm)-pB.*e(pm);
Hp = [Hp1 Hp2];

%% Reactive power injection measurements [dQdth dQdV] 
% Hq = zeros(numtype(4),numbus*2);
% for a = 1:numtype(4)
%     indQmeas = qindices(a,:);
%     [dQde, dQdf] = reactivePowerInjMeas_rect(e,f,G,B,numbus,buses,adjbuses,indQmeas);
%     Hq(a,:) = [dQde dQdf];
% end
qm = qindices(:,1);
qtempVec = sub2ind([numbus numbus],qm,qm); % get G(m,m) in a vectorized way
qG = G(qtempVec);
qB = B(qtempVec);
qeMat = zeros(numbus,numbus);
qfMat = zeros(numbus,numbus);
qeMat(qtempVec) = e(qm);
qfMat(qtempVec) = f(qm);

Hq1 = qeMat*-B(qm,:)+qfMat*G(qm,:); % the order of multiplication matters; overwise you get transverse
Hq1(qtempVec) = -G(qm,:)*f(qm)-B(qm,:)*e(qm)+qG.*f(qm)-qB.*e(qm);
Hq2 = qeMat*-G(qm,:)-qfMat*B(qm,:);
Hq2(qtempVec) = G(qm,:)*e(qm)-B(qm,:)*f(qm)-qG.*e(qm)-qB.*f(qm);
Hq = [Hq1 Hq2];

%% Voltage magnitude measurements
% Hv = zeros(numtype(5),numbus*2);
% for a = 1:numtype(5)
%     indVmeas = vindices(a,:);
%     [dVde, dVdf] = vMeas_rect(e,f,buses,indVmeas);
%     Hv(a,:) = [dVde dVdf];
% end
Hv1 = zeros(numtype(5),numbus); %dV/de
Hv2 = zeros(numtype(5),numbus); %dV/df
tempindV = sub2ind([numtype(5) numbus],(1:numtype(5)).',vindices(:,1)); % not 100% sure this is right for the general case
Hv1(tempindV) = 2*e(vindices(:,1));
Hv2(tempindV) = 2*f(vindices(:,1));
Hv = [Hv1 Hv2];

%% Other measurements
% %     % Current magnitude measurements
%     %FIX: NOT DEBUGGED OR TESTED
% %     elseif strcmp(type(a),'i') == 1
% %         numImeas = numImeas + 1;
% %         indImeas = indices(a,:);  
% %         [dIijdth dIijdV] = iMeas(theta,V,I,numbus,buses,lines,numImeas,indImeas);
% %         H(a,:) = [dIijdth dIijdV];
%     elseif strcmp(type(a),'th') == 1
%         numthmeas = numthmeas + 1;
%         indthmeas = indices(a,:);
%         [dth2de, dth2df] = thMeas_rect(e,f,numbus,buses,buses_a,indthmeas);
%         H(a,:) = [dth2de dth2df];

H = [Hpf; Hqf; Hp; Hq; Hv];