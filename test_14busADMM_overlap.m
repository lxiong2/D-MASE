% IEEE 14-Bus Case with 4 partitions
% See Kekatos 2013 paper and Korres 2011 paper for more details on the
% measurements and partition lines

clc
clear all
close all
format long

% System parameters
%example_14bus_IEEE_rectADMM
%example_14bus_IEEE_partitions
example_14bus_IEEE_partitions_test

numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

YBus14
%Ybus = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

% Partial G, B matrices for each partition
G1 = G(allbuses1,allbuses1); % get submatrix for Partition 1
B1 = B(allbuses1,allbuses1);

G2 = G(allbuses2,allbuses2); % get submatrix for Partition 2
B2 = B(allbuses2,allbuses2);

G3 = G(allbuses3,allbuses3); % get submatrix for Partition 3
B3 = B(allbuses3,allbuses3);

G4 = G(allbuses4,allbuses4); % get submatrix for Partition 4
B4 = B(allbuses4,allbuses4);

%% Partition a 14-bus system into 4 pieces
%numPart = zeros(numbus*2,1);
numArea = 4;
numPart = 2;
iter = 1;
maxiter = 20;
rho = 1; % step size

% Initialize each partition's state vectors
% x1_k = [bus1 bus2 bus3' bus4' bus5 bus6']
x1_k = zeros(size(allbuses1,1)*2,maxiter); % Area S1: 3 buses, bus 1 is the slack for Partition 1 and the global slack bus for the entire system; if you remove bus1 from x1_k, then the Gain matrix is singular
dx1_k = zeros(size(allbuses1,1)*2,maxiter);
% x2_k = [bus2' bus3 bus4 bus5' bus7 bus8 bus9']
x2_k = zeros(size(allbuses2,1)*2,maxiter); % Area S2: 4 buses, bus 3 is the slack for Partition 2; however, to adjust all slacks to the same reference, need to keep f entry for bus 3
dx2_k = zeros(size(allbuses2,1)*2,maxiter);
% x3_k = [bus5' bus6 bus10' bus11 bus12 bus13 bus14']
x3_k = zeros(size(allbuses3,1)*2,maxiter); % Area S3: 4 buses, bus 6 is the slack for Partition 3; however, to adjust all slacks to the same reference, need to keep f entry for bus 6
dx3_k = zeros(size(allbuses3,1)*2,maxiter);
% x4_k = [bus4' bus7' bus9 bus10 bus11' bus13' bus14]
x4_k = zeros(size(allbuses4,1)*2,maxiter); % Area S4: 3 buses, bus 9 is the slack for Partition 4; however, to adjust all slacks to the same reference, need to keep f entry for bus 9
dx4_k = zeros(size(allbuses4,1)*2,maxiter);

% Constraints: size of adjusted x_k (i.e. size(x_k) + 1 for the new slack bus value)
% c_k = [e1 ... e14 f1 ... f14]
c_k = zeros(numbus*2,maxiter);
c1_k = zeros(size(x1_k,1),1);
c2_k = zeros(size(x2_k,1),1);
c3_k = zeros(size(x3_k,1),1);
c4_k = zeros(size(x4_k,1),1);

y1_kl = zeros(size(x1_k,1),maxiter); %same length as x_k vector
y2_kl = zeros(size(x2_k,1),maxiter);
y3_kl = zeros(size(x3_k,1),maxiter);
y4_kl = zeros(size(x4_k,1),maxiter);

normres_r = zeros(1,maxiter);
normres_s = zeros(1,maxiter);

f1 = zeros(1,maxiter);
f2 = zeros(1,maxiter);
f3 = zeros(1,maxiter);
f4 = zeros(1,maxiter);

% initialize first guess
% x1_k = [e1 e2 e3' e4' e5 e6' f2 f3' f4' f5 f6'] %f1 - bus 1 is slack
% x2_k = [e2' e3 e4 e5' e7 e8 e9' f2' f4 f5' f7 f8 f9'] % f3 - bus 3 is the
% slack
% x3_k = [e5' e6 e11 e12 e13 e14' f5' f11 f12 f13 f14'] % f6 - bus 6 is
% the slack
% x4_k = [e4' e7' e9 e10 e11' e13' e14 f4' f7' f10 f11' f13' f14] % f9 - bus 9 is the
% slack
x1_k(:,1) = [ones(size(allbuses1,1),1); zeros(size(allbuses1,1),1)]; %AC flat start
x2_k(:,1) = [ones(size(allbuses2,1),1); zeros(size(allbuses2,1),1)]; %AC flat start
x3_k(:,1) = [ones(size(allbuses3,1),1); zeros(size(allbuses3,1),1)]; %AC flat start
x4_k(:,1) = [ones(size(allbuses4,1),1); zeros(size(allbuses4,1),1)]; %AC flat start

normres_r(:,1) = 1; %primal residual - initialize to nonzero number
normres_s(:,1) = 1; %dual residual - initialize to nonzero number

%% Establish stopping conditions
eps_abs = 1e-4; % machine epsilon
eps_rel = 1e-2;
n = 2*numbus;

%eps_pri = sqrt(n)*eps_abs + eps_rel*max([norm(x1_k) norm(x2_k) norm(x3_k) norm(x4_k) norm(c_k)])
%eps_dual = sqrt(n)*eps_abs + eps_rel*max([norm(y1_kl) norm(y2_kl) norm(y3_kl) norm(y4_kl)])

eps_pri = 1e-4
eps_dual = 1e-4

while ((sqrt(normres_r(:,iter)) > eps_pri) || (sqrt(normres_s(:,iter)) > eps_dual)) && (iter < maxiter)
 
    % Partition 1 calculations
    [tempf1, tempGain1, tempg1, tempH1, temph1] = myfun_Part1_overlap(buses, numbus, allbuses1, adjbuses, lines1, slackIndex1, G1, B1, allz1, allR1, alltype1, allindices1, x1_k(:,iter), c1_k(:,iter), y1_kl(:,iter), rho);
    f1(:,iter) = tempf1;
    Gain1(:,:,iter) = tempGain1;
    g1(:,iter) = tempg1;
    H1(:,:,iter) = tempH1;
    h1(:,iter) = temph1;
    dx1_k(:,iter+1) = -Gain1(:,:,iter)\g1(:,iter);
    dx1_k(numbus1+slackIndex1,iter+1) = 0;
    x1_k(:,iter+1) = x1_k(:,iter) + dx1_k(:,iter+1);
    
    % Partition 2 calculations
    [tempf2, tempGain2, g2, tempH2, temph2] = myfun_Part2_overlap(buses, numbus, allbuses2, adjbuses, lines2, slackIndex2, G2, B2, allz2, allR2, alltype2, allindices2, x2_k(:,iter), c2_k(:,iter), y2_kl(:,iter), rho);
    Gain2(:,:,iter) = tempGain2;
    H2(:,:,iter) = tempH2;
    h2(:,iter) = temph2;
    f2(:,iter+1) = tempf2;
    dx2_k(:,iter+1) = -Gain2(:,:,iter)\g2;
    dx2_k(numbus2+slackIndex2,iter+1) = 0;
    x2_k(:,iter+1) = x2_k(:,iter) + dx2_k(:,iter+1);
   
    % Partition 3 calculations
    [tempf3, tempGain3, g3, tempH3, temph3] = myfun_Part2_overlap(buses, numbus, allbuses3, adjbuses, lines3, slackIndex3, G3, B3, allz3, allR3, alltype3, allindices3, x3_k(:,iter), c3_k(:,iter), y3_kl(:,iter), rho);
    Gain3(:,:,iter) = tempGain3;
    H3(:,:,iter) = tempH3;
    h3(:,iter) = temph3;
    f3(:,iter+1) = tempf3;
    dx3_k(:,iter+1) = -Gain3(:,:,iter)\g3;
    dx3_k(numbus3+slackIndex3,iter+1) = 0;
    x3_k(:,iter+1) = x3_k(:,iter) + dx3_k(:,iter+1);
   
    % Partition 4 calculations
    [tempf4, tempGain4, g4, tempH4, temph4] = myfun_Part2_overlap(buses, numbus, allbuses4, adjbuses, lines4, slackIndex4, G4, B4, allz4, allR4, alltype4, allindices4, x4_k(:,iter), c4_k(:,iter), y4_kl(:,iter), rho);
    Gain4(:,:,iter) = tempGain4;
    H4(:,:,iter) = tempH4;
    h4(:,iter) = temph4;
    f4(:,iter+1) = tempf4;
    dx4_k(:,iter+1) = -Gain4(:,:,iter)\g4;
    dx4_k(numbus4+slackIndex4,iter+1) = 0;
    x4_k(:,iter+1) = x4_k(:,iter) + dx4_k(:,iter+1);
    
    % Reference all the other partitions to the global index and then
    % take the global slack area - the area you want to reference to the
    % global slack bus
    allStates = zeros(numbus*2,numArea);
    allStates(allbuses1,1) = x1_k(1:numbus1,iter+1);
    allStates(numbus+allbuses1,1) = x1_k(numbus1+1:2*numbus1,iter+1);
    allStates(allbuses2,2) = x2_k(1:numbus2,iter+1);
    allStates(numbus+allbuses2,2) = x2_k(numbus2+1:2*numbus2,iter+1);
    allStates(allbuses3,3) = x3_k(1:numbus3,iter+1);
    allStates(numbus+allbuses3,3) = x3_k(numbus3+1:2*numbus3,iter+1);
    allStates(allbuses4,4) = x4_k(1:numbus4,iter+1);
    allStates(numbus+allbuses4,4) = x4_k(numbus4+1:2*numbus4,iter+1);
    
    % Find the shared buses between Area 1 (bus 1 is the global slack) and
    % the other areas, and calc Area 1 angles - Area X angles
    commonStates12 = intersect(allbuses1,allbuses2);
    commonStates13 = intersect(allbuses1,allbuses3);
    commonStates14 = intersect(allbuses1,allbuses4);
    diffSlack = zeros(numbus,3);
    diffSlack(commonStates12,1) = atan(allStates(numbus+commonStates12,1)./allStates(commonStates12,1)) - atan(allStates(numbus+commonStates12,2)./allStates(commonStates12,2));
    diffSlack(commonStates13,2) = atan(allStates(numbus+commonStates13,1)./allStates(commonStates13,1)) - atan(allStates(numbus+commonStates13,3)./allStates(commonStates13,3));
    diffSlack(commonStates14,3) = atan(allStates(numbus+commonStates14,1)./allStates(commonStates14,1)) - atan(allStates(numbus+commonStates14,4)./allStates(commonStates14,4));
    
    diffSlack(commonStates12,1) = atan(allStates(numbus+commonStates12,1)./allStates(commonStates12,1)) - atan(allStates(numbus+commonStates12,2)./allStates(commonStates12,2));
    diffSlack(commonStates13,2) = atan(allStates(numbus+commonStates13,1)./allStates(commonStates13,1)) - atan(allStates(numbus+commonStates13,3)./allStates(commonStates13,3));
    diffSlack(commonStates14,3) = atan(allStates(numbus+commonStates14,1)./allStates(commonStates14,1)) - atan(allStates(numbus+commonStates14,4)./allStates(commonStates14,4));
    
    % Take the average of the difference in slack angles
    % Assume Vmag = 1 -> addE = 1 cos 
    addSlack = zeros(1,size(diffSlack,2));
    for a = 1:size(diffSlack,2)
        temp = diffSlack(:,a);
        addSlack(a) = mean(temp(temp~=0));
    end
        
    % Convert the other areas to the global reference (Area 1 in this case)
    for a = 1:numbus
        for b = 2:numArea
            newe(a,b-1) = allStates(a,b)*cos(addSlack(b-1)) - allStates(numbus+a,b)*sin(addSlack(b-1));
            newf(a,b-1) = allStates(numbus+a,b)*cos(addSlack(b-1)) + allStates(a,b)*sin(addSlack(b-1));
        end
    end
    allStates(:,2:4) = [newe; newf];
      
    x1_k(:,iter+1) = [allStates(allbuses1,1); allStates(numbus+allbuses1,1)];
    x2_k(:,iter+1) = [allStates(allbuses2,2); allStates(numbus+allbuses2,2)];
    x3_k(:,iter+1) = [allStates(allbuses3,3); allStates(numbus+allbuses3,3)];
    x4_k(:,iter+1) = [allStates(allbuses4,4); allStates(numbus+allbuses4,4)];
    
    % Look at allStates and average the buses that overlap
    % How global variables are collected and averaged
    % matches up with the global c indexing
    for a = 1:numbus*2
        numPart(a) = sum(allStates(a,:)~=0);
        temp(a) = sum(allStates(a,:));
        if numPart(a) > 0
            c_k(a,iter+1) = temp(a)/numPart(a);
        end
    end
    c_k;

    % DEBUGGING ONLY
%     newth = zeros(numbus,3);
%     newV = zeros(numbus,3);
%     for a = 1:numbus
%         for b = 1:3
%             newV(a,b) = sqrt(newe(a,b)^2+newf(a,b)^2);
%             if newe(a,b) ~= 0
%                 newth(a,b) = atan(newf(a,b)/newe(a,b));
%             end
%         end
%     end
%     newV
%     newth
   
    % Remap from global c_k to the indexing for each partition's state
    % vector; get rid of each area's slack bus
    % DEBUG - also need automatic function to do that
    c1_k(:,iter+1) = [c_k(allbuses1,iter+1); c_k(numbus+allbuses1,iter+1)];
    c2_k(:,iter+1) = [c_k(allbuses2,iter+1); c_k(numbus+allbuses2,iter+1)];
    c3_k(:,iter+1) = [c_k(allbuses3,iter+1); c_k(numbus+allbuses3,iter+1)];
    c4_k(:,iter+1) = [c_k(allbuses4,iter+1); c_k(numbus+allbuses4,iter+1)];
        
    y1_kl(:,iter+1) = y1_kl(:,iter) + rho*(x1_k(:,iter+1) - c1_k(:,iter+1));
    y2_kl(:,iter+1) = y2_kl(:,iter) + rho*(x2_k(:,iter+1) - c2_k(:,iter+1));
    y3_kl(:,iter+1) = y3_kl(:,iter) + rho*(x3_k(:,iter+1) - c3_k(:,iter+1));
    y4_kl(:,iter+1) = y4_kl(:,iter) + rho*(x4_k(:,iter+1) - c4_k(:,iter+1));
    
    tempnorm1(:,iter+1) = x1_k(:,iter+1) - c1_k(:,iter+1);
    tempnorm2(:,iter+1) = x2_k(:,iter+1) - c2_k(:,iter+1);
    tempnorm3(:,iter+1) = x3_k(:,iter+1) - c3_k(:,iter+1);
    tempnorm4(:,iter+1) = x4_k(:,iter+1) - c4_k(:,iter+1);
    
    normres_r(:,iter+1) = (norm(x1_k(:,iter+1) - c1_k(:,iter+1)))^2 +...
                          (norm(x2_k(:,iter+1) - c2_k(:,iter+1)))^2 +...
                          (norm(x3_k(:,iter+1) - c3_k(:,iter+1)))^2 +...
                          (norm(x4_k(:,iter+1) - c4_k(:,iter+1)))^2;
    normres_s(:,iter+1) = numPart(:,1).*rho^2*(norm(c_k(:,iter+1) - c_k(:,iter)))^2;
    
    iter = iter+1;
end

tempnorm1
tempnorm2
tempnorm3
tempnorm4

% x1_k
% x2_k
% x3_k
% x4_k

figure(1)
semilogy(sqrt(normres_r))
hold on
semilogy(sqrt(normres_s))
title('4-Partition, 14-Bus State Estimation Consensus Problem')
legend('Primal residual', 'Dual residual')

% figure(2)
% clf
% plot(f1)
% hold on
% plot(f2)
% title('2-Partition, 3-Bus State Estimation Consensus Problem')
% legend('Partition 1 obj function','Partition 2 obj function')