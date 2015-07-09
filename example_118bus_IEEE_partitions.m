% IEEE 118-bus case
% NOTES:
% 1. Changed line 69 to be 42-29-2 instead of both 68/69 being designated as 42-29-1
% 2. Changed line 81 to be 49-66-2
% 3. Changed line 83 to be 49-54-2
% 4. Changed line 98 to be 56-58-2
% 5. Changed line 97 to be 56-59-2
% 6. Changed line 132 to be 77-80-2
% 7. Changed line 152 to be 89-92-2
% 8. Changed line 154 to be 89-90-2

simauto = actxserver('pwrworld.SimulatorAuto');

% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

% NOTE: Check case file path before running
simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 bus_2parts.pwb')

% Automatically save Ybus
%simauto.RunScriptCommand('SaveYbusInMatlabFormat("C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\YBus.m",NO)');

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
globalSlackArea = 1;
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

%% Get which buses belong in which partitions
[onlybuses, tiebuses, tielines] = getPartitions(numParts,buses,areas,numlines,lines,option,filename); % get which buses belong in each area

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

% %% Partition 1
% % Don't forget to include the overlap buses!
% allbuses1 = sort([buses1; tiebuses1]);
% numareabus1 = size(buses1,1); % only buses in area
% numbus1 = size(allbuses1,1); % includes buses in area + tie buses
% 
% % Get AC line data for Partition 1
% lines1 = [];
% % If both buses are in Partition 1, include them in lines1
% for a = 1:numlines
%     if ismember(lines(a,1),buses1)==1 && ismember(lines(a,2),buses1)==1
%         lines1 = [lines1; lines(a,:)]; 
%     end
% end
% % Then also include the tie lines
% lines1 = [lines1; tielines1];         
% numlines1 = size(lines1,1);
% 
% alltype1(1:2*numlines1,:) = repmat({'pf'; 'qf'}, [numlines1 1]);
% alltype1(2*numlines1+(1:numareabus1),:) = repmat({'v'}, [numareabus1 1]);
% alltype1(2*numlines1+numareabus1+1:(2*numlines1+3*numareabus1),:)= repmat({'p'; 'q'}, [numareabus1 1]);
% 
% allR1 = diag(0.01^2*ones(1,size(alltype1,1)));
% 
% % FIX: Need to include those boundary measurements
% allindices1 = zeros(2*numlines1+3*numareabus1,3);
% for a = 1:numlines1
%     allindices1((2*a-1):(2*a),:) = [lines1(a,1:3); lines1(a,1:3)]; 
% end
% for a = 1:numareabus1
%     allindices1(2*numlines1+a,1) = buses1(a);
% end
% for a = 1:numareabus1
%     allindices1(2*numlines1+numareabus1+((2*a-1):(2*a)),1) = buses1(a);
% end                     

% Automatically pull "measurements" from PowerWorld case
autoMeas2

%% Slack buses (one for each partition), except the global slack goes in the
% partition with it in the state vector
slack = cell(numParts,1);
slackIndex = cell(numParts,1);
for a = 1:numParts
    if intersect(globalSlack,areabuses{a}) == 1
        slack{a} = globalSlack;
    else
        slack{a} = areabuses{a}(1);
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