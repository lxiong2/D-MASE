clc
clear all

simauto = actxserver('pwrworld.SimulatorAuto');
simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\TVASummer15Base.pwb');

fieldarray = {'BusNum', 'BusNum:1', 'LineCircuit', 'LineXfmr'};
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
lines = [str2double(results{2}{1}), str2double(results{2}{2}), str2double(results{2}{3})];
linexfmr = results{2}{4};
numlines = length(lines);

simauto.RunScriptCommand('EnterMode(Edit)');

% Cycle through all of the lines in the case to convert each transformer to
% a line
str = sprintf('setdata(branch,[LineXfmr],[NO],ALL);');
simauto.RunScriptCommand(str);

test = simauto.SaveCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\TVASummer15Base_lines.pwb','PWB',true);

simauto.CloseCase();
delete(simauto);