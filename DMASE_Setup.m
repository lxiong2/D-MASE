% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% % NOTE: Delete the blank line at the end of graph_XXX.txt
% filename = 'graph118_4parts.txt'; % only matters if option = 3
% numParts = 4; % should match filename if option = 3
% casename = 118;

simauto = actxserver('pwrworld.SimulatorAuto');

% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

% NOTE: Check case file path before running
simauto.OpenCase(casepath)

% Automatically save Ybus
%simauto.RunScriptCommand('SaveYbusInMatlabFormat("C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\YBus14.m",NO)');

simauto.RunScriptCommand('EnterMode(Run)');

% Run rectangular Newton-Raphson power flow
simauto.RunScriptCommand('SolvePowerFlow(RECTNEWT,,,,)');

% Get the list of buses in the system
fieldarray = {'BusNum','BusSlack','AreaNum'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('bus',fieldarray,'');
buses = str2double(results{2}{1});
numbus = size(buses,1);
busIndex = (1:numbus).';
areas = str2double(results{2}{3});

% Get the slack bus number
%globalSlack = buses(strcmp(results{2}{2},'YES'));
globalSlack = 1;
globalSlackIndex = busIndex(buses == globalSlack);

%% Line Information
% Get line parameters for full AC system
fieldarray = {'BusNum','BusNum:1','LineCircuit','LineR','LineX','LineC'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
lines = [str2double(results{2}{1}) str2double(results{2}{2}) str2double(results{2}{3})...
         str2double(results{2}{4}) str2double(results{2}{5}) str2double(results{2}{6})];
numlines = size(lines,1);     

% list of adjacent buses
% NOTE: preset the size of adjbuses to be 15, may need to change that for
% larger cases
temp = zeros(numbus,numbus);
for a = 1:numlines
    temp(lines(a,1),lines(a,2)) = temp(lines(a,1),lines(a,2)) + 1;
    temp(lines(a,2),lines(a,1)) = temp(lines(a,2),lines(a,1)) + 1;
end

adjbuses = zeros(numbus,15);
for a = 1:numbus
    temp2 = find(temp(a,:) ~= 0);
    adjbuses(a,1:size(temp2,2)) = temp2;
end
adjbuses = [(1:numbus).' adjbuses];
            
% Get power flow line results
fieldarray = {'BusNum','BusNum:1','LineCircuit','LineMW','LineMVR','LineMW:1','LineMVR:1'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
MWflows = str2double(results{2}{4})/100; 
MVARflows = str2double(results{2}{5})/100;
revMWflows = str2double(results{2}{6})/100;
revMVARflows = str2double(results{2}{7})/100;

fieldarray = {'BusNum','BusPUVolt','BusGenMW','BusGenMVR','BusLoadMW','BusLoadMVR'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('bus',fieldarray,'');
busV = str2double(results{2}{2}).^2; % need to square the bus voltages, since I'm using rectangular coordinates
genMW = str2double(results{2}{3})/100;
genMVAR = str2double(results{2}{4})/100;
loadMW = str2double(results{2}{5})/100;
loadMVAR = str2double(results{2}{6})/100;

simauto.CloseCase();
delete(simauto);

%% Get which buses belong in which partitions
[onlybuses, tiebuses, tielines, globalSlackArea] = getPartitions(numParts,buses,globalSlack,areas,numlines,lines,option,casename,filename); % get which buses belong in each area
%[onlybuses, tiebuses, tielines, globalSlackArea, adjacentAreas] = getPartitions(numParts,buses,globalSlack,areas,numlines,lines,option,casename,filename); % get which buses belong in each area

%% Full measurement information from PowerWorld AC power flow results
areabuses = cell(numParts,1);
numareabus = cell(numParts,1);
numonlybus = cell(numParts,1);

arealines = cell(numParts,1);
numarealines = cell(numParts,1);

alltype = cell(numParts,1);
allR = cell(numParts,1);
allindices = cell(numParts,1);

% Go through each partition and autogenerate the type, indices, and R
% matrices
for a = 1:numParts
    areabuses{a} = sort([onlybuses{a}; tiebuses{a}]); %all buses in area including tie buses
    numareabus{a} = size(areabuses{a},1); %includes buses in area + tie buses
    numonlybus{a} = size(onlybuses{a},1); %only the buses in area
    
    temp = [];    
    for b = 1:numlines
        if ismember(lines(b,1),onlybuses{a})==1 && ismember(lines(b,2),onlybuses{a})==1
            temp = [temp; lines(b,:)]; 
        end
    end
    arealines{a} = [temp; tielines{a}];
    numarealines{a} = size(arealines{a},1);
    
    alltype{a} = [repmat({'pf'; 'qf'}, [numarealines{a} 1]);
                  repmat({'v'}, [numonlybus{a} 1]);
                  repmat({'p'; 'q'}, [numonlybus{a} 1])];

    allR{a} = diag(0.01^2*ones(1,size(alltype{a},1)));

    % FIX: Need to include those boundary measurements
    allindices{a} = zeros(2*numarealines{a}+3*numonlybus{a},3);
    for b = 1:numarealines{a}
        allindices{a}((2*b-1):(2*b),:) = [arealines{a}(b,1:3); arealines{a}(b,1:3)]; 
    end
    for b = 1:numonlybus{a}
        allindices{a}(2*numarealines{a}+b,1) = onlybuses{a}(b);
    end
    for b = 1:numonlybus{a}
        allindices{a}(2*numarealines{a}+numonlybus{a}+((2*b-1):(2*b)),1) = onlybuses{a}(b);
    end
end

% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

% Get rid of NaN so you can calculate gen - load
for a = 1:numbus
    if isnan(genMW(a))
        genMW(a) = 0;
    end
    if isnan(genMVAR(a))
        genMVAR(a) = 0;
    end
    if isnan(loadMW(a))
        loadMW(a) = 0;
    end
    if isnan(loadMVAR(a))
        loadMVAR(a) = 0;
    end
end

busMW = genMW - loadMW;
busMVAR = genMVAR - loadMVAR;

numMeas = cell(numParts,1);
allz = cell(numParts,1);
for a = 1:numParts
    numMeas{a} = size(allindices{a},1);
    allz{a} = getMeas(lines,numMeas{a},allindices{a},alltype{a},MWflows,MVARflows,revMWflows,revMVARflows,busV,busMW,busMVAR);
end

%% Slack buses (one for each partition), except the global slack goes in the
% partition with it in the state vector
slack = cell(numParts,1);
slackIndex = cell(numParts,1);
for a = 1:numParts
    if intersect(globalSlack,onlybuses{a}) == 1
        slack{a} = globalSlack;
    else
        slack{a} = onlybuses{a}(1);
    end
    busIndex = (1:numareabus{a}).';
    slackIndex{a} = busIndex(areabuses{a}==slack{a});
end
           
%% Aggregated measurements
z = [];
type = [];
indices = [];
for a = 1:numParts
    z = [z; allz{a}];
    type = [type; alltype{a}];
    indices = [indices; allindices{a}];
end
R = diag(0.01^2*ones(1,size(z,1)));