% IEEE 118-Bus Case with 2 partitions
% Uses full AC rectangular power flow for the state estimation formulation
% See Kekatos 2013 paper and Korres 2011 paper for more details on the
% measurements and partition lines

clc
clear all
close all
format long

% Get system parameters and partitions
option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
filename = 'graph_2parts.txt'; % only matters if option = 3
numParts = 2; % should match filename if option = 3

example_118bus_IEEE_partitions

numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

YBus
G = real(Ybus);
B = imag(Ybus);

% Partial G, B matrices for each partition
areaG = cell(numParts,1);
areaB = cell(numParts,1);
for a = 1:numParts
    areaG{a} = G(areabuses{a},areabuses{a}); % get submatrix for each partition
    areaB{a} = B(areabuses{a},areabuses{a});
end

%% Run distributed multi-area state estimation
iter = 1;
maxiter = 2;
rho = 1; % step size

% Initialize each partition's state vectors
% Area S1: 3 buses, bus 1 is the slack for Partition 1 and the global slack bus for the entire system; if you remove bus1 from x1_k, then the Gain matrix is singular
% Area S2: 4 buses, bus 3 is the slack for Partition 2; however, to adjust all slacks to the same reference, need to keep f entry for bus 3

x_k = cell(numParts,1);
dx_k = cell(numParts,1);
areac_k = cell(numParts,1);
areay_kl = cell(numParts,1);
objfn = cell(numParts,1);
for a = 1:numParts
    x_k{a} = zeros(numareabus{a}*2,maxiter); 
    dx_k{a} = zeros(numareabus{a}*2,maxiter);
    areac_k{a} = zeros(size(x_k{a},1),maxiter);
    areay_kl{a} = zeros(size(x_k{a},1),maxiter); %same length as x_k vector
    objfn{a} = zeros(1,maxiter); % objective function
end

% Constraints: size of adjusted x_k (i.e. size(x_k) + 1 for the new slack bus value)
% c_k = [e1 ... e14 f1 ... f14]
c_k = zeros(numbus*2,maxiter);

normres_r = zeros(1,maxiter);
normres_s = zeros(1,maxiter);

% initialize first guess - AC flat start
for a = 1:numParts
    x_k{a}(:,1) = [ones(numareabus{a},1); zeros(numareabus{a},1)];
end

normres_r(:,1) = 1; %primal residual - initialize to nonzero number
normres_s(:,1) = 1; %dual residual - initialize to nonzero number

%% Establish stopping conditions
eps_abs = 1e-4; % machine epsilon
eps_rel = 1e-2;
n = 2*numbus;

%eps_pri = sqrt(n)*eps_abs + eps_rel*max([norm(x1_k) norm(x2_k) norm(x3_k) norm(x4_k) norm(c_k)])
%eps_dual = sqrt(n)*eps_abs + eps_rel*max([norm(y1_kl) norm(y2_kl) norm(y3_kl) norm(y4_kl)])

eps_pri = 1e-5
eps_dual = 1e-5

while ((sqrt(normres_r(:,iter)) > eps_pri) || (sqrt(normres_s(:,iter)) > eps_dual)) && (iter < maxiter)

    % Do distributed state estimation for each partition
    for a = 1:numParts
        [tempobjfn, tempGain, tempg, temph, tempH] = myfun_overlap(buses, numbus, areabuses{a}, adjbuses, arealines{a}, slackIndex{a}, areaG{a}, areaB{a}, allz{a}, allR{a}, alltype{a}, allindices{a}, x_k{a}(:,iter), areac_k{a}(:,iter), areay_kl{a}(:,iter), rho);
        objfn{a}(:,iter) = tempobjfn;
        Gain{a}(:,:,iter) = tempGain;
        g{a}(:,iter) = tempg;
        h{a}(:,iter) = temph;
        H{a}(:,:,iter) = tempH;
        dx_k{a}(:,iter+1) = -Gain{a}(:,:,iter)\g{a}(:,iter);
        dx_k{a}(numareabus{a}+slackIndex{a},iter+1) = 0;
        x_k{a}(:,iter+1) = x_k{a}(:,iter) + dx_k{a}(:,iter+1);
    end
       
    % Reference all the other partitions to the global index and then
    % take the global slack area - the area you want to reference to the
    % global slack bus
    allStates = zeros(numbus*2,numParts);
    for a = 1:numParts
        allStates(areabuses{a},a) = x_k{a}(1:numareabus{a},iter+1);
        allStates(numbus+areabuses{a},a) = x_k{a}(numareabus{a}+1:2*numareabus{a},iter+1);
    end
      
    % Find the shared buses between Area 1 (bus 1 is the global slack) and
    % the other areas, and calc Area 1 angles - Area X angles
    
    commonStates = cell(numParts,1);
    diffSlack = zeros(numbus,numParts-1);
    for a = 2:numParts
        commonStates{a} = intersect(areabuses{1},areabuses{a});
        diffSlack(commonStates{a},a-1) = atan(allStates(numbus+commonStates{a},1)./allStates(commonStates{a},1)) - atan(allStates(numbus+commonStates{a},a)./allStates(commonStates{a},a));
    end
    
    %% Take the average of the difference in slack angles
    % Assume Vmag = 1 -> addE = 1 cos 
    addSlack = zeros(1,size(diffSlack,2));
    for a = 1:size(diffSlack,2)
        temp = diffSlack(:,a);
        addSlack(a) = mean(temp(temp~=0));
    end
    
    % Convert the other areas to the global reference (Area 1 in this case)
    for b = 2:numParts
        for a = 1:numbus
            newe(a,b-1) = allStates(a,b)*cos(addSlack(b-1)) - allStates(numbus+a,b)*sin(addSlack(b-1));
            newf(a,b-1) = allStates(numbus+a,b)*cos(addSlack(b-1)) + allStates(a,b)*sin(addSlack(b-1));
        end
        allStates(:,b) = [newe(:,b-1); newf(:,b-1)];
    end
    
    for a = 1:numParts
        x_k{a}(:,iter+1) = [allStates(areabuses{a},a); allStates(numbus+areabuses{a},a)];
    end
    
    % Look at allStates and average the buses that overlap
    % How global variables are collected and averaged
    % matches up with the global c indexing
    numDivide = zeros(1,numbus*2);
    for a = 1:numbus*2
        numDivide(a) = sum(allStates(a,:)~=0);
        temp(a) = sum(allStates(a,:));
        if numDivide(a) > 0
            c_k(a,iter+1) = temp(a)/numDivide(a);
        end
    end
    c_k;

    % Remap from global c_k to the indexing for each partition's state
    % vector; get rid of each area's slack bus
    % DEBUG - also need automatic function to do that
    for a = 1:numParts
        areac_k{a}(:,iter+1) = [c_k(areabuses{a},iter+1); c_k(numbus+areabuses{a},iter+1)];
        areay_kl{a}(:,iter+1) = areay_kl{a}(:,iter) + rho*(x_k{a}(:,iter+1) - areac_k{a}(:,iter+1));
    end
    
    normres_r(:,iter+1) = 0;
    for a = 1:numParts
        normres_r(:,iter+1) = normres_r(:,iter+1) + (norm(x_k{a}(:,iter+1) - areac_k{a}(:,iter+1)))^2;
    end
    
    normres_s(:,iter+1) = numDivide(:,1).*rho^2*(norm(c_k(:,iter+1) - c_k(:,iter)))^2;
    
    iter = iter+1;
end

figure(1)
semilogy(sqrt(normres_r))
hold on
semilogy(sqrt(normres_s))
title('N-Partition, 118-Bus State Estimation Consensus Problem')
legend('Primal residual', 'Dual residual')

% figure(2)
% clf
% plot(f1)
% hold on
% plot(f2)
% title('2-Partition, 3-Bus State Estimation Consensus Problem')
% legend('Partition 1 obj function','Partition 2 obj function')