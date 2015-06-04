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
simauto.RunScriptCommand('SaveYbusInMatlabFormat("C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\YBus.m",NO)');

simauto.RunScriptCommand('EnterMode(Run)');

% Get the list of buses in the system
fieldarray = {'BusNum','BusSlack'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('bus',fieldarray,'');
buses = str2double(results{2}{1});
numbus = size(buses,1);
busIndex = (1:numbus).';

% Get the slack bus number
globalSlack = buses(strcmp(results{2}{2},'YES'));
globalSlackArea = 2;
globalSlackIndex = busIndex(buses == globalSlack);

%% Line Information
% Get line data for full AC system
fieldarray = {'BusNum','BusNum:1','LineCircuit','LineR','LineX','LineC'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
lines = [str2double(results{2}{1}) str2double(results{2}{2}) str2double(results{2}{3})...
         str2double(results{2}{4}) str2double(results{2}{5}) str2double(results{2}{6})];
numlines = size(lines,1);     

% Tie lines
% 23 CollCrnr to 24 Trenton
% 47 Crooksvl to 69 Sporn
% 49 Philo to 69 Sporn
% 65 Muskngum to 68 Sporn

tielines1 = [23 24 1 0.01350 0.04920 0.04980;
            47 69 1 0.08440 0.27780 0.07092;
            49 69 1 0.09850 0.32400 0.08280;
            65 68 1 0.00138 0.01600 0.63800];

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
            
%% Full measurement information from PowerWorld AC power flow results

% Partition 1
% Don't forget to include the overlap buses!
buses1 = [(1:23).'; (25:47).'; (48:58).'; (60:67).'; (113:115).'; 117];
tiebuses1 = [24; 68; 69];
allbuses1 = [buses1; tiebuses1];
numbus1 = size(allbuses1,1);

% Get AC line data for Partition 1
lines1 = [];
% If both buses are in Partition 1, include them in lines1
for a = 1:numlines
    if ismember(lines(a,1),buses1)==1 && ismember(lines(a,2),buses1)==1
        lines1 = [lines1; lines(a,:)]; 
    end
end
% Then also include the tie lines
lines1 = [lines1; tielines1];         
numlines1 = size(lines1,1);

alltype1(1:2*numlines1,:) = repmat({'pf'; 'qf'}, [numlines1 1]);
alltype1(2*numlines1+(1:numbus1),:) = repmat({'v'}, [numbus1 1]);
alltype1(2*numlines1+numbus1+1:(2*numlines1+3*numbus1),:)= repmat({'p'; 'q'}, [numbus1 1]);

allR1 = diag(0.01^2*ones(1,size(alltype1,1)));

% FIX: Need to include those boundary measurements
allindices1 = zeros(2*numlines1+3*numbus1,3);
for a = 1:numlines1
    allindices1((2*a-1):(2*a),:) = [lines1(a,1:3); lines1(a,1:3)]; 
end
for a = 1:numbus1
    allindices1(2*numlines1+a,1) = allbuses1(a);
end
for a = 1:numbus1
    allindices1(2*numlines1+numbus1+((2*a-1):(2*a)),1) = allbuses1(a);
end                     

%% Partition 2
% The non-chronological bus numbers are the boundary states
buses2 = [24; 58; (68:112).'; 116; 118];
tiebuses2 = [23; 47; 49; 65];
allbuses2 = [buses2; tiebuses1];
numbus2 = size(allbuses2,1);

% Get AC line data for Partition 2    
lines2 = [];
% If both buses are in Partition 2, include them in lines2
for a = 1:numlines
    if ismember(lines(a,1),buses2)==1 && ismember(lines(a,2),buses2)==1
        lines2 = [lines2; lines(a,:)]; 
    end
end
% Then also include the tie lines
lines2 = [lines2; tielines12];
numlines2 = size(lines2,1);

alltype2(1:2*numlines2,:) = repmat({'pf'; 'qf'}, [numlines2 1]);
alltype2(2*numlines2+1:(2*numlines2+numbus2),:) = repmat({'v'}, [numbus2 1]);
alltype2(2*numlines2+numbus2+1:(2*numlines2+3*numbus2),:)= repmat({'p'; 'q'}, [numbus2 1]);

allR2 = diag(0.01^2*ones(1,size(alltype2,1)));

% FIX: Need to include those boundary measurements
allindices2 = zeros(2*numlines2+3*numbus2,3);
for a = 1:numlines2
    allindices2((2*a-1):(2*a),:) = [lines2(a,1:3); lines2(a,1:3)]; 
end
for a = 1:numbus2
    allindices2(2*numlines2+a,1) = allbuses2(a);
end
for a = 1:numbus2
    allindices2(2*numlines2+numbus2+((2*a-1):(2*a)),1) = allbuses2(a);
end

% Automatically pull "measurements" from PowerWorld case
autoMeas2

simauto.CloseCase();

% Slack buses (one for each partition)
slack1 = allbuses1(1);
slack2 = globalSlack;
busIndex1 = (1:numbus1).';
busIndex2 = (1:numbus2).';
slackIndex1 = busIndex1(allbuses1==slack1);
slackIndex2 = busIndex2(allbuses2==slack2);
           
%% Aggregated measurements
z = [allz1; allz2];
R = diag(0.01^2*ones(1,size(z,1)));
type = [alltype1; alltype2];
indices = [allindices1; allindices2];
