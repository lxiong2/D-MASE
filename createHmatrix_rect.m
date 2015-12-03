function H = createHmatrix_rect(e,f,G,B,numtype,indices,numbus,buses,lines,adjbuses)

H = zeros(sum(numtype),numbus*2);

%% Initialize
Hpf = zeros(numtype(1),numbus*2); % Real power flow
Hqf = zeros(numtype(2),numbus*2); % Reactive power flow
Hp = zeros(numtype(3),numbus*2); % Real power injection
Hq = zeros(numtype(4),numbus*2); % Reactive power injection
Hv = zeros(numtype(5),numbus*2); % Voltage

pfindices = indices(1:numtype(1),:);
qfindices = indices(numtype(1)+(1:numtype(2)),:);
pindices = indices(numtype(1)+numtype(2)+(1:numtype(3)),:);
qindices = indices(numtype(1)+numtype(2)+numtype(3)+(1:numtype(4)),:);
vindices = indices(numtype(1)+numtype(2)+numtype(3)+numtype(4)+(1:numtype(5)),:);

%% Determine type of measurement
% Real power flow measurements [dPijdth dPijdV]
for a = 1:numtype(1)
    indPFmeas = pfindices(a,:);
    [dPijde, dPijdf] = realPowerFlowMeas_rect(e,f,G,B,buses,lines,indPFmeas);
    Hpf(a,:) = [dPijde dPijdf];
end
% Reactive power flow measurements [dQijdth dQijdV]   
for a = 1:numtype(2)
    indQFmeas = qfindices(a,:);
    [dQijde, dQijdf] = reactivePowerFlowMeas_rect(e,f,G,B,buses,lines,indQFmeas);
    Hqf(a,:) = [dQijde dQijdf];
end
% Real power injection measurements [dPdth dPdV]
for a = 1:numtype(3)
    indPmeas = pindices(a,:);
    [dPde, dPdf] = realPowerInjMeas_rect(e,f,G,B,numbus,buses,adjbuses,indPmeas);
    Hp(a,:) = [dPde dPdf];
end
% Reactive power injection measurements [dQdth dQdV]   
for a = 1:numtype(4)
    indQmeas = qindices(a,:);
    [dQde, dQdf] = reactivePowerInjMeas_rect(e,f,G,B,numbus,buses,adjbuses,indQmeas);
    Hq(a,:) = [dQde dQdf];
end
% Voltage magnitude measurements
for a = 1:numtype(5)
    indVmeas = vindices(a,:);
    [dVde, dVdf] = vMeas_rect(e,f,buses,indVmeas);
    Hv(a,:) = [dVde dVdf];
end

% indVmeas = vindices(:,1);
% vIndex = zeros(numtype(5),1);
% vIndex = 
% [vm,vn]=ind2sub([numtype(5) numbus*2], ); 
% Hv(:,indVmeas)=2*e(indVmeas)
% vMatrix = zeros(numtype(5),numtype(5));
% Hv2 = vMatrix*f(indVmeas);
% Hv = [Hv1 Hv2]

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