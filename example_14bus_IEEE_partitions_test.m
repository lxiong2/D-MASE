% IEEE 14-bus case
% see topology and measurement data from Korres 2011 
% "A distributed multiarea state estimation" 

clc
clear all

simauto = actxserver('pwrworld.SimulatorAuto');

% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

% NOTE: Check case file path before running
simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb')

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

% Tie lines
tielines1 = [2 3 1 0.04699 0.19797 0.0438;
             2 4 1 0.05811 0.17632 0.034;
             4 5 1 0.01335 0.04211 0;
             5 6 1 0 0.25202 0];
        
tielines2 = [2 3 1 0.04699 0.19797 0.0438;
             4 5 1 0.01335 0.04211 0;
             4 9 1 0 0.55618 0;
             7 9 1 0 0.11001 0];
         
tielines3 = [5 6 1 0 0.25202 0;
             10 11 1 0.08205 0.19207 0;
             13 14 1 0.17093 0.34802 0];
         
tielines4 = [4 9 1 0 0.55618 0;
             7 9 1 0 0.11001 0;
             10 11 1 0.08205 0.19207 0;
             13 14 1 0.17093 0.34802 0];

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
            
%% Full measurement information from PowerWorld AC power flow results

% Partition 1
% Don't forget to include the overlap buses!
buses1 = [1; 2; 5];
tiebuses1 = [3; 4; 6];
allbuses1 = [buses1; tiebuses1];
numbus1 = size(buses1,1);

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
buses2 = [3; 4; 7; 8];
tiebuses2 = [2; 5; 9];
allbuses2 = [buses2; tiebuses2];
numbus2 = size(buses2,1);

% Get AC line data for Partition 2    
lines2 = [];
% If both buses are in Partition 2, include them in lines2
for a = 1:numlines
    if ismember(lines(a,1),buses2)==1 && ismember(lines(a,2),buses2)==1
        lines2 = [lines2; lines(a,:)]; 
    end
end
% Then also include the tie lines
lines2 = [lines2; tielines2];
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

%% Partition 3
% The non-chronological bus numbers are the boundary states
buses3 = [6; 11; 12; 13];
tiebuses3 = [5; 10; 14];
allbuses3 = [buses3; tiebuses3];
numbus3 = size(buses3,1);

% Get AC line data for Partition 3    
lines3 = [];
% If both buses are in Partition 3, include them in lines3
for a = 1:numlines
    if ismember(lines(a,1),buses3)==1 && ismember(lines(a,2),buses3)==1
        lines3 = [lines3; lines(a,:)]; 
    end
end
% Then also include the tie lines
lines3 = [lines3; tielines3];
numlines3 = size(lines3,1);

alltype3(1:2*numlines3,:) = repmat({'pf'; 'qf'}, [numlines3 1]);
alltype3(2*numlines3+1:(2*numlines3+numbus3),:) = repmat({'v'}, [numbus3 1]);
alltype3(2*numlines3+numbus3+1:(2*numlines3+3*numbus3),:)= repmat({'p'; 'q'}, [numbus3 1]);

allR3 = diag(0.01^2*ones(1,size(alltype3,1)));

% FIX: Need to include those boundary measurements
allindices3 = zeros(2*numlines3+3*numbus3,3);
for a = 1:numlines3
    allindices3((2*a-1):(2*a),:) = [lines3(a,1:3); lines3(a,1:3)]; 
end
for a = 1:numbus3
    allindices3(2*numlines3+a,1) = allbuses3(a);
end
for a = 1:numbus3
    allindices3(2*numlines3+numbus3+((2*a-1):(2*a)),1) = allbuses3(a);
end

%% Partition 4
% The non-chronological bus numbers are the boundary states
buses4 = [9; 10; 14];
tiebuses4 = [4; 7; 11; 13];
allbuses4 = [buses4; tiebuses4];
numbus4 = size(buses4,1);

% Get AC line data for Partition 4    
lines4 = [];
% If both buses are in Partition 4, include them in lines2
for a = 1:numlines
    if ismember(lines(a,1),buses4)==1 && ismember(lines(a,2),buses4)==1
        lines4 = [lines4; lines(a,:)]; 
    end
end
% Then also include the tie lines
lines4 = [lines4; tielines4];
numlines4 = size(lines4,1);

alltype4(1:2*numlines4,:) = repmat({'pf'; 'qf'}, [numlines4 1]);
alltype4(2*numlines4+1:(2*numlines4+numbus4),:) = repmat({'v'}, [numbus4 1]);
alltype4(2*numlines4+numbus4+1:(2*numlines4+3*numbus4),:)= repmat({'p'; 'q'}, [numbus4 1]);

allR4 = diag(0.01^2*ones(1,size(alltype4,1)));

% FIX: Need to include those boundary measurements
allindices4 = zeros(2*numlines4+3*numbus4,3);
for a = 1:numlines4
    allindices4((2*a-1):(2*a),:) = [lines4(a,1:3); lines4(a,1:3)]; 
end
for a = 1:numbus4
    allindices4(2*numlines4+a,1) = allbuses4(a);
end
for a = 1:numbus4
    allindices4(2*numlines4+numbus4+((2*a-1):(2*a)),1) = allbuses4(a);
end

% Automatically pull "measurements" from PowerWorld case
autoMeas_14bus

simauto.CloseCase();

% %% Line Information
% % AC line data
% lines1 = [1 2 1 0.01938 0.05917 0.0528;
%           1 5 1 0.05403 0.22304 0.0492;
%           2 5 1 0.05695 0.17388 0.0346;
%           % Tie lines
%           2 3 1 0.04699 0.19797 0.0438;
%           2 4 1 0.05811 0.17632 0.034;
%           4 5 1 0.01335 0.04211 0;
%           5 6 1 0 0.25202 0
%           ];
%      
% lines2 = [3 4 1 0.06701 0.17103 0.0128;
%           4 7 1 0 0.20912 0;
%           7 8 1 0 0.17615 0;
%           % Tie lines
%           2 3 1 0.04699 0.19797 0.0438;
%           4 5 1 0.01335 0.04211 0;
%           4 9 1 0 0.55618 0;
%           7 9 1 0 0.11001 0];
%       
% lines3 = [6 11 1 0.09498 0.1989 0;
%           6 12 1 0.12291 0.25581 0;
%           6 13 1 0.06615 0.13027 0;
%           12 13 1 0.22092 0.19988 0;
%           % Tie lines
%           5 6 1 0 0.25202 0;
%           10 11 1 0.08205 0.19207 0;
%           13 14 1 0.17093 0.34802 0];
%          
% lines4 = [9 10 1 0.03181 0.0845 0;
%           9 14 1 0.12711 0.27038 0;
%           % Tie lines
%           4 9 1 0 0.55618 0;
%           7 9 1 0 0.11001 0;
%           10 11 1 0.08205 0.19207 0;
%           13 14 1 0.17093 0.34802 0];
% 
% % list of adjacent buses
% adjbuses = [1 2 5 0 0 0;
%             2 1 3 4 5 0;
%             3 2 4 0 0 0;
%             4 2 3 5 7 9;
%             5 1 2 4 6 0;
%             6 5 11 12 13 0;
%             7 4 8 9 0 0;
%             8 7 0 0 0 0;
%             9 4 7 10 14 0;
%             10 9 11 0 0 0; 
%             11 6 10 0 0 0;
%             12 6 13 0 0 0;
%             13 6 12 14 0 0;
%             14 9 13 0 0 0];
% 
% %% Full measurement information from PowerWorld AC power flow results
% 
% % Partition 1
% % x1_k = [bus1 bus2 bus3' bus4' bus5 bus6']
% 
% numbus1 = size(allbuses1,1);
% alltype1 = {'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v';
%             'p'; 'q'; 'p'; 'q'; 'p'; 'q';
%             'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'
%             };
% allR1 = diag(0.01^2*ones(1,size(alltype1,1)));        
% allindices1 = [1 2 1;
%                1 2 1;
%                1 5 1;
%                1 5 1;
%                2 5 1;
%                2 5 1;
%                1 0 0;
%                2 0 0;
%                5 0 0;
%                1 0 0;
%                1 0 0;
%                2 0 0;
%                2 0 0;
%                5 0 0;
%                5 0 0;
%                % Boundary measurements
%                2 3 1;
%                2 3 1;
%                5 4 1;
%                5 4 1;
%                5 6 1;
%                5 6 1
%                ];
% 
% %% Partition 2
% % x2_k = [bus2' bus3 bus4 bus5' bus7 bus8 bus9']
% allbuses2 = [2; 3; 4; 5; 7; 8; 9];
% numbus2 = size(allbuses2,1);
% alltype2 = {'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v'; 'v';
%             'p'; 'q'; 'p'; 'q'; 'p'; 'q'; 'p'; 'q';
%             'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'};
% allR2 = diag(0.01^2*ones(1,size(alltype2,1)));        
% allindices2 = [3 4 1;
%                3 4 1;
%                4 7 1;
%                4 7 1;
%                7 8 1;
%                7 8 1;
%                3 0 0;
%                4 0 0;
%                7 0 0;
%                8 0 0;
%                3 0 0;
%                3 0 0;
%                4 0 0;
%                4 0 0;
%                7 0 0;
%                7 0 0;
%                8 0 0;
%                8 0 0;
%                3 2 1;
%                3 2 1;
%                4 5 1;
%                4 5 1;
%                7 9 1;
%                7 9 1];
% 
% %% Partition 3
% % x3_k = [bus5' bus6 bus10' bus11 bus12 bus13 bus14']
% allbuses3 = [5; 6; 10; 11; 12; 13; 14];
% numbus3 = size(allbuses3,1);
% alltype3 = {'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v'; 'v';
%             'p'; 'q'; 'p'; 'q'; 'p'; 'q'; 'p'; 'q';
%             'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'};
% allR3 = diag(0.01^2*ones(1,size(alltype3,1)));        
% allindices3 = [6 11 1;
%                6 11 1;
%                6 12 1;
%                6 12 1;
%                6 13 1; 
%                6 13 1;
%                12 13 1;
%                12 13 1;
%                6 0 0;
%                11 0 0;
%                12 0 0;
%                13 0 0;
%                6 0 0;
%                6 0 0;
%                11 0 0;
%                11 0 0;
%                12 0 0;
%                12 0 0;
%                13 0 0;
%                13 0 0;
%                % Boundary measurements
%                6 5 1;
%                6 5 1;
%                11 10 1;
%                11 10 1;
%                13 14 1;
%                13 14 1];
% 
% %% Partition 4
% % x4_k = [bus4' bus7' bus9 bus10 bus11' bus13' bus14]
% allbuses4 = [4; 7; 9; 10; 11; 13; 14];
% numbus4 = size(allbuses4,1);
% alltype4 = {'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v';
%             'p'; 'q'; 'p'; 'q'; 'p'; 'q';
%             'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'};
% allR4 = diag(0.01^2*ones(1,size(alltype4,1)));         
% allindices4 = [9 10 1;
%                9 10 1;
%                9 14 1;
%                9 14 1;
%                9 0 0;
%                10 0 0;
%                14 0 0;
%                9 0 0;
%                9 0 0;
%                10 0 0;
%                10 0 0;
%                14 0 0;
%                14 0 0;
%                % Boundary measurements
%                9 4 1;
%                9 4 1;
%                9 7 1;
%                9 7 1;
%                10 11 1;
%                10 11 1;
%                14 13 1;
%                14 13 1];
% 
% % Automatically pull "measurements" from PowerWorld case
% autoMeas
% simauto.CloseCase();

% Slack buses (one for each partition)
slack1 = 1;
slack2 = 3;
slack3 = 6;
slack4 = 9;
busIndex1 = (1:numbus1).';
busIndex2 = (1:numbus2).';
busIndex3 = (1:numbus3).';
busIndex4 = (1:numbus4).';
slackIndex1 = busIndex1(allbuses1==slack1);
slackIndex2 = busIndex2(allbuses2==slack2);
slackIndex3 = busIndex3(allbuses3==slack3);
slackIndex4 = busIndex4(allbuses4==slack4);
           
%% Aggregated measurements
z = [allz1; allz2; allz3; allz4];
R = diag(0.01^2*ones(1,size(z,1)));
type = [alltype1; alltype2; alltype3; alltype4];
indices = [allindices1; allindices2; allindices3; allindices4];
