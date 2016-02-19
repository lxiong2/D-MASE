clc
clear

simauto = actxserver('pwrworld.SimulatorAuto');

% NOTE: Check case file path before running
%simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb')
%simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 57 bus.pwb')
simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE300Bus.pwb')
%simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\TVASummer15Base_onlylines_Consolidated.pwb')
%simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 bus_2parts.pwb')
%simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus_doublelines.pwb')

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
delete(simauto);

busIndex = (1:numbus).';

temp = zeros(numbus,numbus);
b = 1;
c = 1;
for a = 1:numlines
    m = busIndex(lines(a,2)==buses);
    n = busIndex(lines(a,1)==buses);
    temp(n,b) = m;
    temp(m,c) = n;
    b = b + 1;
    c = c + 1;
end

%% Overwrite the graph text file
fid = fopen('graph300.txt','w');

% initial line of input file with 
fprintf(fid, '%d %d\n', [numbus numlines]);

for a = 1:numbus
    temp2 = temp(a,:);
    adjbuses = temp2(temp2~=0);
    str = repmat('%d ',[1 size(adjbuses,2)]);
    fprintf(fid, str, adjbuses);
    fprintf(fid, '\n');
end

fid = fclose(fid);