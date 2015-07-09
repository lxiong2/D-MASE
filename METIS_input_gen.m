clc
clear

simauto = actxserver('pwrworld.SimulatorAuto');

% NOTE: Check case file path before running
simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 bus_2parts.pwb')

simauto.RunScriptCommand('EnterMode(Run)');

% Get the list of buses in the system
fieldarray = {'BusNum'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('bus',fieldarray,'');
buses = str2double(results{2}{1});
numbus = size(buses,1);

% Line Information
% Get line data for full AC system
fieldarray = {'BusNum','BusNum:1','LineCircuit'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
lines = [str2double(results{2}{1}) str2double(results{2}{2}) str2double(results{2}{3})];
numlines = size(lines,1);     

simauto.CloseCase();

temp = zeros(numbus,numbus);
b = 1;
c = 1;
for a = 1:numlines
    temp(lines(a,1),b) = lines(a,2);
    temp(lines(a,2),c) = lines(a,1);
    b = b + 1;
    c = c + 1;
end

%% Overwrite the graph text file
fid = fopen('graph.txt','w');

% initial line of input file with 
fprintf(fid, '%d %d\n', [numbus numlines]);

for a = 1:numbus
    temp2 = temp(a,:);
    adjbuses = temp2(temp2~=0)
    str = repmat('%d ',[1 size(adjbuses,2)]);
    fprintf(fid, str, adjbuses);
    fprintf(fid, '\n');
end

fid = fclose(fid);