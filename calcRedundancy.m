clc
clear all

% numlines = 20;
% numbuses = 14;

% numlines = 80;
% numbuses = 57;

% numlines = 186;
% numbuses = 118;

% numlines = 411;
% numbuses = 300;

numlines = 2405
numbuses = 1435;

numMeas = 2*numlines+3*numbuses;
numStates = 2*numbuses;

redundancyRatio = numMeas/numStates