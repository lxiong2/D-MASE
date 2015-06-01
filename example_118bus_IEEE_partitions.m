clc
clear all

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
globalSlackArea = 1;
globalSlackIndex = busIndex(buses == globalSlack);

%% Line Information
% Get line data for full AC system
fieldarray = {'BusNum','BusNum:1','LineCircuit','LineR','LineX','LineC'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
lines = [str2double(results{2}{1}) str2double(results{2}{2}) str2double(results{2}{3})...
         str2double(results{2}{4}) str2double(results{2}{5}) str2double(results{2}{6})];
numlines = size(lines,1);     

% list of adjacent buses
% adjbuses = zeros(numbus,numbus);
% b = 1;
% for a = 1:numlines
%     adjbuses(numlines(a,1),numlines
%     
% end

adjbuses = [1 2 5 0 0 0;
            2 1 3 4 5 0;
            3 2 4 0 0 0;
            4 2 3 5 7 9;
            5 1 2 4 6 0;
            6 5 11 12 13 0;
            7 4 8 9 0 0;
            8 7 0 0 0 0;
            9 4 7 10 14 0;
            10 9 11 0 0 0; 
            11 6 10 0 0 0;
            12 6 13 0 0 0;
            13 6 12 14 0 0;
            14 9 13 0 0 0];

%% Full measurement information from PowerWorld AC power flow results

% Partition 1
% Don't forget to include the overlap buses!
allbuses1 = [(1:23).'; (25:47).'; (48:58).'; (60:67).'; (113:115).'; 117]; % does not include overlap buses yet
numbus1 = size(allbuses1,1);

% Get AC line data for Partition 1
lines1 = [];
for a = 1:numlines
    if ismember(lines(a,1),allbuses1)==1 || ismember(lines(a,2),allbuses1)==1
        lines1 = [lines1; lines(a,:)]; 
    end
end
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
allbuses2 = [24; 58; (68:112).'; 116; 118];
numbus2 = size(allbuses2,1);

% Get AC line data for Partition 2    
lines2 = [];
for a = 1:numlines
    if ismember(lines(a,1),allbuses2)==1 || ismember(lines(a,2),allbuses2)==1
        lines2 = [lines2; lines(a,:)]; 
    end
end
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
slack1 = 1;
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
