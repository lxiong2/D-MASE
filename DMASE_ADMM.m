% Uses full AC rectangular power flow for the state estimation formulation
% See Kekatos 2013 paper for more details

clc
clear all
close all
format long

%reps = 1;
%centralt = zeros(1,reps);
centralt = 0;

% Get system parameters and partitions
% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb';
% filename = 'graph14_14parts.txt'; % only matters if option = 3
% newfilename = 'graph14_14parts (2).txt';
% numParts = 14; % should match filename if option = 3
% casename = 14;
% YBus14
% load noise14.mat
% load noisetype14.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 57 bus.pwb';
% filename = 'graph57_57parts.txt'; % only matters if option = 3; none=rb; (2)=k-way contig
% newfilename = 'graph57_57parts (2).txt';
% numParts = 57;
% casename = 57;
% YBus57
% load noise57.mat
% load noisetype57.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_2parts.pwb';
% filename = 'graph118_118parts.txt'; % only matters if option = 3
% newfilename = 'graph118_118parts (2).txt';
% numParts = 118; % should match filename if option = 3
% casename = 118;
% YBus118
% load noise118.mat
% load noisetype118.mat

option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE300Bus.pwb';
filename = 'graph300_128parts.txt'; % only matters if option = 3
newfilename = 'graph300_128parts (2).txt';
numParts = 128;
casename = 300;
YBus300
load noise300.mat
load noisetype300.mat


% Read METIS output file and see how many actual partitions there are, then
% overwrite numParts
METIS_out = dlmread(filename,'\n').';
listParts = unique(METIS_out);
allParts = (0:numParts-1).';
emptyParts = setdiff(allParts,listParts); % numbering starts from 0 (part 0,1,...,N-1)
numParts = numParts-size(emptyParts,1)

% Overwrite METIS file with new partition numbering if there are empty
% partitions
if size(emptyParts,1) ~= 0
    fid = fopen(newfilename,'w');
    for a = 1:casename
        temp = METIS_out(a);
        for b = 1:size(emptyParts,1)
            if METIS_out(a) > emptyParts(b)
                temp = temp-1;
            end
        end
        fprintf(fid, '%d', temp);
        if a ~= casename
            fprintf(fid, '\n');
        end
    end
    fid = fclose(fid);
    filename = newfilename;
end

% Get partitions and set up measurement information from PowerWorld
DMASE_Setup                                                     

lineStatus = repmat({'Closed'},[numlines 1]);

% Form the neighborAreas list
adjAreas = unique(areaconns(:,1:2),'rows'); % [from bus area, to bus area]
neighborAreas = cell(numParts,1);
tempIndex = (1:size(adjAreas,1)).';
for a = 1:numParts
    temp1 = tempIndex(adjAreas(:,1)==a);
    temp2 = tempIndex(adjAreas(:,2)==a);
    neighborAreas{a} = unique(sort([adjAreas(temp1,2); adjAreas(temp2,1)]));
end

% YBus
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
maxiter = 5;
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

eps_pri = 1e-2;
eps_dual = 1e-2;

%centralt = zeros(numParts,1);
%tic %tic toc PAIR 3/3
while ((sqrt(normres_r(:,iter)) > eps_pri) || (sqrt(normres_s(:,iter)) > eps_dual)) && (iter < maxiter)
    % Do distributed state estimation for each partition
    tic % tic toc PAIR 1/3
    for a = 1:numParts
        [tempobjfn, tempGain, tempg, temph, tempH] = myfun_overlap(buses, numbus, areabuses{a}, adjbuses, arealines{a}, slackIndex{a}, areaG{a}, areaB{a}, allz{a}, allR{a}, alltype{a}, allindices{a}, x_k{a}(:,iter), areac_k{a}(:,iter), areay_kl{a}(:,iter), rho);
        objfn{a}(:,iter) = tempobjfn;
        Gain{a}(:,:,iter) = tempGain;
        g{a}(:,iter) = tempg;
        h{a}(:,iter) = temph;
        H{a}(:,:,iter) = tempH;
%         dx_k{a}(:,iter+1) = -Gain{a}(:,:,iter)\g{a}(:,iter);
%         dx_k{a}(numareabus{a}+slackIndex{a},iter+1) = 0;
        tempdx_k{a} = -Gain{a}(:,:,iter)\g{a}(:,iter);
        dx_k{a}(:,iter+1) = [tempdx_k{a}(1:numareabus{a}+slackIndex{a}-1); 0; tempdx_k{a}(numareabus{a}+slackIndex{a}:numareabus{a}*2-1)];
        x_k{a}(:,iter+1) = x_k{a}(:,iter) + dx_k{a}(:,iter+1);
    end
    partitiont(iter) = toc; % tic toc PAIR 1/3
    
    tic % tic toc PAIR 2/3
    % Reference all the other partitions to the global index and then
    % take the global slack area - the area you want to reference to the
    % global slack bus
    allStates = zeros(numbus*2,numParts);
    for a = 1:numParts
        allStates(areabuses{a},a) = x_k{a}(1:numareabus{a},iter+1);
        allStates(numbus+areabuses{a},a) = x_k{a}(numareabus{a}+1:2*numareabus{a},iter+1);
    end

    [newStates,polarStates,distance,parent] = ref2GlobalSlack(allStates,numbus,numParts,areabuses,neighborAreas,globalSlackArea);
    
    allStates = newStates;
    
    for a = 1:numParts
        x_k{a}(:,iter+1) = [allStates(areabuses{a},a); allStates(numbus+areabuses{a},a)];
    end
    
    % Look at allStates and average the buses that overlap
    % How global variables are collected and averaged
    % matches up with the global c indexing
    numDivide = zeros(1,numbus*2);
    for a = 1:numbus*2
        numDivide(a) = sum(allStates(a,:)~=0);
        tempSum(a) = sum(allStates(a,:));
        if numDivide(a) > 0
            c_k(a,iter+1) = tempSum(a)/numDivide(a);
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
    ADMMt(iter) = toc; % tic toc PAIR 2/3 
    
    iter = iter+1;
end
%centralt = toc; %tic toc PAIR 3/3

%end

totalt = sum(partitiont)+sum(ADMMt)
perPartition = sum(partitiont)/totalt;
perADMM = sum(ADMMt)/totalt;

%centralt

% Global Polar States
globalPolarSoln = zeros(2*numbus,1);
for a = 1:numbus
    globalPolarSoln(a,1) = atan(c_k(numbus+a,iter)/c_k(a,iter));
    if isnan(globalPolarSoln(a,1)) == 1
        globalPolarSoln(a,1) = 0;
    end
	globalPolarSoln(numbus+a,1) = sqrt(c_k(a,iter)^2+c_k(numbus+a,iter)^2);
end
globalPolarSoln = globalPolarSoln - globalPolarSoln(1,:);

% Compacted polar states
% Convert to polar coordinates for debug purposes
compactPolarStates = cell(numParts,1);
for a = 1:numParts
    compactPolarStates{a} = [polarStates(areabuses{a},a); polarStates(numbus+areabuses{a},a)];
end

% Compare polarStates against PW's centralized power flow solution
errReport = [];
diffReport = [];
errThreshold = 1e-4;
diffTrueSoln = zeros(numbus*2,numParts);
compactDiffTrueSoln = cell(numParts,1);
diffIndex = [buses; buses];
if option == 2
    areaList = unique(areas);
elseif option == 3
    areaList = (1:numParts).';
end
    
for a = 1:numParts
    tempCentral = zeros(numbus*2,1);
    tempCentral(areabuses{a}) = centralPWStates(areabuses{a});
    tempCentral(numbus+areabuses{a}) = centralPWStates(numbus+areabuses{a});
    diffTrueSoln(:,a) = tempCentral - polarStates(:,a);
    compactDiffTrueSoln{a} = [centralPWStates(areabuses{a}) - polarStates(areabuses{a},a); centralPWStates(numbus+areabuses{a}) - polarStates(numbus+areabuses{a},a)];
    for b = 1:numbus*2
        % Flag bus numbers of problem buses, i.e. if diffTrueSoln is higher than a specified error threshold
        if diffTrueSoln(b,a) > errThreshold
            errReport = [errReport; a diffIndex(b) diffTrueSoln(b,a)];
        end
    end
    for b = 1:size(areabuses{a},1)
        miniDiffIndex = [areabuses{a}; areabuses{a}];
        if abs(compactPolarStates{a}(b)) > 0.5
            diffReport = [diffReport; a areaList(a) miniDiffIndex(b) 1 compactPolarStates{a}(b)];
        end
        if (abs(compactPolarStates{a}(size(areabuses{a},1)+b)) > 1.5) || (abs(compactPolarStates{a}(size(areabuses{a},1)+b)) < 0.7)
            diffReport = [diffReport; a areaList(a) miniDiffIndex(b) 2 compactPolarStates{a}(b)];
        end
    end
end
% errReport
% diffReport
% 
figure(1)
semilogy(sqrt(normres_r))
hold on
semilogy(sqrt(normres_s))
title('N-Partition Distributed Multi-Area State Estimation Consensus Problem')
legend('Primal residual', 'Dual residual')