clc
clear all

%% Test case 1: chain overlap
% areabuses = cell(3,1);
% areabuses{1} = [1; 2];
% areabuses{2} = [2; 3; 4];
% areabuses{3} = [4; 5];
% 
% allStates = [0 0 0;
%              2 -1 0;
%              0 0 0;
%              0 5 -2;
%              0 0 0];
% 
% numbus = 5;
% buses = (1:numbus).';
% numAreas = 3;
% 
% neighborAreas = cell(4,1);
% neighborAreas{1} = 2;
% neighborAreas{2} = [1; 3];
% neighborAreas{3} = 2;
   
%% Test case 2: group overlap
% numbus = 6;
% numParts = 3;
% 
% areabuses = cell(3,1);
% areabuses{1} = [1; 2; 6];
% areabuses{2} = [2; 3; 4];
% areabuses{3} = [4; 5; 6];
% 
% neighborAreas = cell(3,1);
% neighborAreas{1} = [2; 3];
% neighborAreas{2} = [1; 3];
% neighborAreas{3} = [1; 2];

% allStates = [0 0 0;
%              2 -1 0;
%              0 0 0;
%              0 5 -2;
%              0 0 0;
%              15 0 5];

% allStates = [1 0 0;
%              1.014904249 1.018725266 0;
%              0 1.04 0;
%              0 1.058675276 1.054704415;
%              0 0 1.08;
%              1.013167093 0 1.094504582;
%              0 0 0;
%              0.101830085 -0.050978753 0;
%              0 0 0;
%              0 0.052977919 -0.105823422;
%              0 0 0;
%              0.428360177 0 0.109816758];

%% Test 3 group: arbitrary topology
numbus = 17;
numParts = 8;

areabuses = cell(8,1);
areabuses{1} = [1; 2];
areabuses{2} = [2; 3; 4; 8];
areabuses{3} = [4; 5; 6; 10];
areabuses{4} = [6; 7];
areabuses{5} = [8; 9; 12; 13; 15];
areabuses{6} = [10; 11; 12];
areabuses{7} = [13; 14; 17];
areabuses{8} = [15; 16; 17];

neighborAreas = cell(8,1);
neighborAreas{1} = 2;
neighborAreas{2} = [1; 3; 5];
neighborAreas{3} = [2; 4; 6];
neighborAreas{4} = 3;
neighborAreas{5} = [2; 6; 7; 8];
neighborAreas{6} = [3; 5];
neighborAreas{7} = [5; 8];
neighborAreas{8} = [5; 7];

polarStates = [0	0	0	0	0	0	0	0;
                0.01	-0.01	0	0	0	0	0	0;
                0	0	0	0	0	0	0	0;
                0	0.02	-0.02	0	0	0	0	0;
                0	0	0	0	0	0	0	0;
                0	0	0.02	-0.03	0	0	0	0;
                0	0	0	0	0	0	0	0;
                0	0.12	0	0	-0.03	0	0	0;
                0	0	0	0	0	0	0	0;
                0	0	0.15	0	0	-0.04	0	0;
                0	0	0	0	0	0	0	0;
                0	0	0	0	0.12	0.04	0	0;
                0	0	0	0	0.17	0	-0.05	0;
                0	0	0	0	0	0	0	0;
                0	0	0	0	0.27	0	0	-0.05;
                0	0	0	0	0	0	0	0;
                0	0	0	0	0	0	0.15	0.05;
                1	0	0	0	0	0	0	0;
                1	1	0	0	0	0	0	0;
                0	1	0	0	0	0	0	0;
                0	1	1	0	0	0	0	0;
                0	0	1	0	0	0	0	0;
                0	0	1	1	0	0	0	0;
                0	0	0	1	0	0	0	0;
                0	1	0	0	1	0	0	0;
                0	0	0	0	1	0	0	0;
                0	0	1	0	0	1	0	0;
                0	0	0	0	0	1	0	0;
                0	0	0	0	1	1	0	0;
                0	0	0	0	1	0	1	0;
                0	0	0	0	0	0	1	0;
                0	0	0	0	1	0	0	1;
                0	0	0	0	0	0	0	1;
                0	0	0	0	0	0	1	1];

globalSlackArea = 4;
            
allStates = convertPolar2Rect(polarStates,numParts,numbus);

[newStates,polarStates,distance,parent] = ref2GlobalSlack(allStates,numbus,numParts,areabuses,neighborAreas,globalSlackArea)
