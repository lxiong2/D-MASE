% IEEE 14-Bus Case with 4 partitions
% See Kekatos 2013 paper and Korres 2011 paper for more details on the
% measurements and partition lines

clc
clear all
close all
format long

% System parameters
example_118bus_IEEE_partitions

numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

YBus
G = real(Ybus);
B = imag(Ybus);

% Partial G, B matrices for each partition
G1 = G(allbuses1,allbuses1); % get submatrix for Partition 1
B1 = B(allbuses1,allbuses1);

G2 = G(allbuses2,allbuses2); % get submatrix for Partition 2
B2 = B(allbuses2,allbuses2);

%% Partition a 14-bus system into 4 pieces
numArea = 2;
numPart = 2;
iter = 1;
maxiter = 5;
rho = 1; % step size

% Initialize each partition's state vectors
% x1_k = [bus1 bus2 bus3' bus4' bus5 bus6']
x1_k = zeros(size(allbuses1,1)*2,maxiter); % Area S1: 3 buses, bus 1 is the slack for Partition 1 and the global slack bus for the entire system; if you remove bus1 from x1_k, then the Gain matrix is singular
dx1_k = zeros(size(allbuses1,1)*2,maxiter);
% x2_k = [bus2' bus3 bus4 bus5' bus7 bus8 bus9']
x2_k = zeros(size(allbuses2,1)*2,maxiter); % Area S2: 4 buses, bus 3 is the slack for Partition 2; however, to adjust all slacks to the same reference, need to keep f entry for bus 3
dx2_k = zeros(size(allbuses2,1)*2,maxiter);

% Constraints: size of adjusted x_k (i.e. size(x_k) + 1 for the new slack bus value)
% c_k = [e1 ... e14 f1 ... f14]
c_k = zeros(numbus*2,maxiter);
c1_k = zeros(size(x1_k,1),1);
c2_k = zeros(size(x2_k,1),1);

y1_kl = zeros(size(x1_k,1),maxiter); %same length as x_k vector
y2_kl = zeros(size(x2_k,1),maxiter);

normres_r = zeros(1,maxiter);
normres_s = zeros(1,maxiter);

f1 = zeros(1,maxiter);
f2 = zeros(1,maxiter);

% initialize first guess
% x1_k = [e1 e2 e3' e4' e5 e6' f2 f3' f4' f5 f6'] %f1 - bus 1 is slack
% x2_k = [e2' e3 e4 e5' e7 e8 e9' f2' f4 f5' f7 f8 f9'] % f3 - bus 3 is the
% slack
x1_k(:,1) = [ones(size(allbuses1,1),1); zeros(size(allbuses1,1),1)]; %AC flat start
x2_k(:,1) = [ones(size(allbuses2,1),1); zeros(size(allbuses2,1),1)]; %AC flat start

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
    
    % Reference all the other partitions to the global index and then
    % take the global slack area - the area you want to reference to the
    % global slack bus
    allStates = zeros(numbus*2,numArea);
    allStates(allbuses1,1) = x1_k(1:numbus1,iter+1);
    allStates(numbus+allbuses1,1) = x1_k(numbus1+1:2*numbus1,iter+1);
    allStates(allbuses2,2) = x2_k(1:numbus2,iter+1);
    allStates(numbus+allbuses2,2) = x2_k(numbus2+1:2*numbus2,iter+1);
    
    % Find the shared buses between Area 1 (bus 1 is the global slack) and
    % the other areas, and calc Area 1 angles - Area X angles
    commonStates12 = intersect(allbuses1,allbuses2);
    diffSlack = zeros(numbus,3);
    diffSlack(commonStates12,1) = atan(allStates(numbus+commonStates12,1)./allStates(commonStates12,1)) - atan(allStates(numbus+commonStates12,2)./allStates(commonStates12,2));
    
    diffSlack(commonStates12,1) = atan(allStates(numbus+commonStates12,1)./allStates(commonStates12,1)) - atan(allStates(numbus+commonStates12,2)./allStates(commonStates12,2));
    
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
    allStates(:,2) = [newe; newf];
      
    x1_k(:,iter+1) = [allStates(allbuses1,1); allStates(numbus+allbuses1,1)];
    x2_k(:,iter+1) = [allStates(allbuses2,2); allStates(numbus+allbuses2,2)];
    
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

    % Remap from global c_k to the indexing for each partition's state
    % vector; get rid of each area's slack bus
    % DEBUG - also need automatic function to do that
    c1_k(:,iter+1) = [c_k(allbuses1,iter+1); c_k(numbus+allbuses1,iter+1)];
    c2_k(:,iter+1) = [c_k(allbuses2,iter+1); c_k(numbus+allbuses2,iter+1)];
        
    y1_kl(:,iter+1) = y1_kl(:,iter) + rho*(x1_k(:,iter+1) - c1_k(:,iter+1));
    y2_kl(:,iter+1) = y2_kl(:,iter) + rho*(x2_k(:,iter+1) - c2_k(:,iter+1));
    
    normres_r(:,iter+1) = (norm(x1_k(:,iter+1) - c1_k(:,iter+1)))^2 +...
                          (norm(x2_k(:,iter+1) - c2_k(:,iter+1)))^2;
    normres_s(:,iter+1) = numPart(:,1).*rho^2*(norm(c_k(:,iter+1) - c_k(:,iter)))^2;
    
    iter = iter+1;
end

figure(1)
semilogy(sqrt(normres_r))
hold on
semilogy(sqrt(normres_s))
title('2-Partition, 118-Bus State Estimation Consensus Problem')
legend('Primal residual', 'Dual residual')

% figure(2)
% clf
% plot(f1)
% hold on
% plot(f2)
% title('2-Partition, 3-Bus State Estimation Consensus Problem')
% legend('Partition 1 obj function','Partition 2 obj function')