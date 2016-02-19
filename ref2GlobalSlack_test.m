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
numbus = 6;
buses = (1:numbus).';
numParts = 3;

areabuses = cell(3,1);
areabuses{1} = [1; 2; 6];
areabuses{2} = [2; 3; 4];
areabuses{3} = [4; 5; 6];

areaconns = [1 2 1 2 1;
             1 2 2 3 1;
             2 3 3 4 1;
             2 3 4 5 1;
             3 1 5 6 1;
             3 1 6 1 1];

% allStates = [0 0 0;
%              2 -1 0;
%              0 0 0;
%              0 5 -2;
%              0 0 0;
%              15 0 5];

allStates = [1 0 0;
             1.014904249 1.018725266 0;
             0 1.04 0;
             0 1.058675276 1.054704415;
             0 0 1.08;
             1.013167093 0 1.094504582;
             0 0 0;
             0.101830085 -0.050978753 0;
             0 0 0;
             0 0.052977919 -0.105823422;
             0 0 0;
             0.428360177 0 0.109816758];
         
for b = 1:numParts
    for a = 1:numbus
        polarStates(a,b) = atan(allStates(numbus+a,b)/allStates(a,b));
        if isnan(polarStates(a,b)) == 1
            polarStates(a,b) = 0;
        end
        polarStates(numbus+a,b) = sqrt(allStates(a,b)^2+allStates(numbus+a,b)^2);
    end
end
polarStates

[newStates,polarStates,neighborAreas] = ref2GlobalSlack(allStates,numbus,buses,numParts,areabuses,areaconns)
