clc
clear all

simauto = actxserver('pwrworld.SimulatorAuto');
simauto.OpenCase('C:\Users\lxiong7.AD\Dropbox\ACES Research\Cybersecurity\IEEE 14.pwb');

simauto.RunScriptCommand('EnterMode(Run)');

% Insert a full list of contingencies 
simauto.RunScriptCommand('CTGAutoInsert');

% Set current case as reference
simauto.RunScriptCommand('CTGSetAsReference');

% Solve all contingencies
simauto.RunScriptCommand('CTGSolveAll(NO)');

% Get results as an auxiliary file - we may need to parse this into a more readable
% form
simauto.RunScriptCommand('CTGWriteResultsAndOptions("C:\Users\lxiong7.AD\Dropbox\ACES Research\Cybersecurity\CAfile.txt",[NO YES NO YES NO YES YES NO NO NO],SECONDARY,NO)');

simauto.CloseCase();
delete(simauto);