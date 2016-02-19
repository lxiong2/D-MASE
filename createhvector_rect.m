function h = createhvector_rect(e,f,G,B,numtype,indices,numbus,lines,paraLineIndex)
% Rectangular power flow
% V_i = e_i + j*f_i = |V_i| ang (theta_i)
% Includes what to do for parallel lines

hpf = zeros(numtype(1),1);
hqf = zeros(numtype(2),1);
hp = zeros(numtype(3),1);
hq = zeros(numtype(4),1);
hv = zeros(numtype(5),1);

pfindices = indices(1:numtype(1),:);
qfindices = indices(numtype(1)+(1:numtype(2)),:);
pindices = indices(numtype(1)+numtype(2)+(1:numtype(3)),:);
qindices = indices(numtype(1)+numtype(2)+numtype(3)+(1:numtype(4)),:);
vindices = indices(numtype(1)+numtype(2)+numtype(3)+numtype(4)+(1:numtype(5)),:);

% Assume gsi = 0

%% Real power flow measurements
% for a = 1:numtype(1)
%     m = find(buses==pfindices(a,1));
%     n = find(buses==pfindices(a,2));
%     ckt = indices(a,3);
%     % Find the indices of the lines that have the same to and from
%     % buses or vice versa
%     paraLines1 = intersect(find(lines(:,1)==pfindices(a,1)),find(lines(:,2)==pfindices(a,2)));
%     paraLines2 = intersect(find(lines(:,2)==pfindices(a,1)),find(lines(:,1)==pfindices(a,2)));
%     paraLines = [paraLines1; paraLines2];
%     if size(paraLines,1) == 1 %no multiple lines (or if the matrix is empty)
%         hpf(a) = -G(m,n)*(e(m)^2+f(m)^2)+G(m,n)*(e(m)*e(n)+f(m)*f(n))+B(m,n)*(f(m)*e(n)-e(m)*f(n));
%     % Look ahead by 2 measurements. If it's a multiple line, then use
%     % current divider to calculate the PF based on their impedances.
%     else %multiple lines
%         lineNum = intersect(paraLines,find(lines(:,3)==ckt));
%         Zeq = lines(lineNum,4)+1i*lines(lineNum,5);         
%         g = real(1/Zeq);
%         b = imag(1/Zeq);
%         % See PowerWorld documentation for derivation
%         gmn = -g;
%         bmn = -b;
%         gmm = g;
%         hpf(a) = gmm*(e(m)^2+f(m)^2)+gmn*(e(m)*e(n)+f(m)*f(n))+bmn*(f(m)*e(n)-e(m)*f(n));
% %         tempt = toc;
% %         temptime = temptime+tempt;
%     end
% end

pfm = pfindices(:,1);
pfn = pfindices(:,2);
% for single branches
pftempVec = sub2ind([numbus numbus],pfm,pfn); % get G(m,n) in a vectorized way
pfG = G(pftempVec);
pfB = B(pftempVec);
hpf = -pfG.*(e(pfm).^2+f(pfm).^2)+pfG.*(e(pfm).*e(pfn)+f(pfm).*f(pfn))+pfB.*(f(pfm).*e(pfn)-e(pfm).*f(pfn));
% for parallel branches
Yeq = 1./(lines(paraLineIndex,4)+1i*lines(paraLineIndex,5));
lilg = real(Yeq);
lilb = imag(Yeq);

pfm2 = pfindices(paraLineIndex,1);
pfn2 = pfindices(paraLineIndex,2);
hpf(paraLineIndex) = lilg.*(e(pfm2).^2+f(pfm2).^2)+-lilg.*(e(pfm2).*e(pfn2)+f(pfm2).*f(pfn2))+-lilb.*(f(pfm2).*e(pfn2)-e(pfm2).*f(pfn2));

%% Reactive power flow measurements
% tic
% for a = 1:numtype(2)
%     m = find(buses==indices(a,1));
%     n = find(buses==indices(a,2));
%     ckt = indices(a,3);
%     % Find the indices of the lines that have the same to and from
%     % buses or vice versa
%     paraLines1 = intersect(find(lines(:,1)==qfindices(a,1)),find(lines(:,2)==qfindices(a,2)));
%     paraLines2 = intersect(find(lines(:,2)==qfindices(a,1)),find(lines(:,1)==qfindices(a,2)));
%     paraLines = [paraLines1; paraLines2];
%     lineNum = intersect(paraLines,find(lines(:,3)==ckt));
%     if lines(lineNum,6) ~= 0
%         bsi = lines(lineNum,6)/2;
%     else bsi = 0;
%     end
%     if size(paraLines,1) == 1  %no multiple lines (or if the matrix is empty)
%         hqf(a) = (B(m,n)-bsi)*(e(m)^2+f(m)^2)-B(m,n)*(e(m)*e(n)+f(m)*f(n))+G(m,n)*(f(m)*e(n)-e(m)*f(n));
%     else %multiple lines
%         Zeq = lines(lineNum,4)+1i*lines(lineNum,5);         
%         g = real(1/Zeq);
%         b = imag(1/Zeq);
%         gmn = -g;
%         bmn = -b;
%         bmm = b+bsi;
%         hqf(a) = -bmm*(e(m)^2+f(m)^2)-bmn*(e(m)*e(n)+f(m)*f(n))-gmn*(e(m)*f(n)-f(m)*e(n));
%     end
% end
% tempt = toc;
% temptime = temptime+tempt;

qfm = qfindices(:,1);
qfn = qfindices(:,2);
% for single branches
qftempVec = sub2ind([numbus numbus],qfm,qfn); % get G(m,n) in a vectorized way
qfG = G(qftempVec);
qfB = B(qftempVec);
bsi = lines(:,6)/2; % DEBUG: not generalized
hqf = (qfB-bsi).*(e(qfm).^2+f(qfm).^2)-qfB.*(e(qfm).*e(qfn)+f(qfm).*f(qfn))+qfG.*(f(qfm).*e(qfn)-e(qfm).*f(qfn));
% for parallel branches
qfm2 = qfindices(paraLineIndex,1);
qfn2 = qfindices(paraLineIndex,2);
hqf(paraLineIndex) = -(lilb+bsi(paraLineIndex)).*(e(qfm2).^2+f(qfm2).^2)+lilb.*(e(qfm2).*e(qfn2)+f(qfm2).*f(qfn2))+lilg.*(e(qfm2).*f(qfn2)-f(qfm2).*e(qfn2));

%% Real power injection measurements
pm = pindices(:,1); % m = bus at which P is injected
ptemp = G(pm,:)*e-B(pm,:)*f;
ptemp2 = G(pm,:)*f+B(pm,:)*e;
hp = e(pm).*ptemp+f(pm).*ptemp2;

%% Reactive power injection measurements
qm = qindices(:,1); % m = bus at which P is injected
qtemp = -G(qm,:)*f-B(qm,:)*e;
qtemp2 = G(qm,:)*e-B(qm,:)*f;
hq = e(qm).*qtemp + f(qm).*qtemp2;

%% Voltage magnitude measurements SQUARED 
% (NOTE: SQUARED, so to get the actual V magnitude, take the sqrt)
vm = vindices(:,1);
hv = e(vm).^2+f(vm).^2;

%% Current magnitude measurements
%     elseif strcmp(type(a),'i') == 1
%     % WARNING: NOT DEBUGGED OR TESTED
%     % ASSUMPTION: ignore the shunt admittance (gsi+1i*bsi)
%         m = busIndex(buses==indices(a,1));
%         n = busIndex(buses==indices(a,2));
%         for c = 1:size(lines,1)
%             if indices(:,1:3) == lines(c,1:3)
%                 lineNum = c;
%             end
%         end
%         ztemp = 1/(lines(lineNum,4)+1i*lines(lineNum,5));
%         gij = real(ztemp);
%         bij = imag(ztemp);
%         h(a) = sqrt((gij^2+bij^2)*(V(m).^2+V(n)^2-...
%             2*V(m)*V(n)*cos(theta(m)-theta(n))));
% Angle measurement from PMUs
%     elseif strcmp(type(a),'th') == 1
%         m = busIndex(buses==indices(a,1));
%         h(a) = theta(m);

h = [hpf; hqf; hp; hq; hv];