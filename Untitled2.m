sharedStates41 = intersect(areabuses{4},areabuses{1}); %find common states between the parent area and the child area 
diffShared41 = mean(atan(temp101(numbus+sharedStates41,4)./temp101(sharedStates41,4))-...
    atan(temp101(numbus+sharedStates41,1)./temp101(sharedStates41,1))); % average delta theta between the two sets of states

% % 4-1-7
% sharedStates17 = intersect(areabuses{1},areabuses{7}); %find common states between the parent area and the child area
% diffShared17 = mean(atan(temp101(numbus+sharedStates17,1)./temp101(sharedStates17,1))-...
%     atan(temp101(numbus+sharedStates17,7)./temp101(sharedStates17,7))); % average delta theta between the two sets of states
% 
% diff417 = diffShared41-diffShared17
% 
% % 4-6-7
% sharedStates46 = intersect(areabuses{4},areabuses{6}); %find common states between the parent area and the child area
% %sharedStates46 = sharedStates46(sharedStates46~=1)
% diffShared46 = mean(atan(temp101(numbus+sharedStates46,4)./temp101(sharedStates46,4))-...
%     atan(temp101(numbus+sharedStates46,6)./temp101(sharedStates46,6))); % average delta theta between the two sets of states
% sharedStates67 = intersect(areabuses{6},areabuses{7}); %find common states between the parent area and the child area
% diffShared67 = mean(atan(temp101(numbus+sharedStates67,6)./temp101(sharedStates67,6))-...
%     atan(temp101(numbus+sharedStates67,7)./temp101(sharedStates67,7))); % average delta theta between the two sets of states
% 
% diff467 = diffShared46-diffShared67


% 4-1-8
sharedStates18 = intersect(areabuses{1},areabuses{8}) %find common states between the parent area and the child area
diffShared18 = mean(atan(temp101(numbus+sharedStates18,1)./temp101(sharedStates18,1))-...
    atan(temp101(numbus+sharedStates18,8)./temp101(sharedStates18,8))) % average delta theta between the two sets of states

diff418 = diffShared41+diffShared18


% 4-5-8
sharedStates45 = intersect(areabuses{4},areabuses{5}) %find common states between the parent area and the child area      
diffShared45 = mean(atan(temp101(numbus+sharedStates45,4)./temp101(sharedStates45,4))-...
    atan(temp101(numbus+sharedStates45,5)./temp101(sharedStates45,5))) % average delta theta between the two sets of states

sharedStates58 = intersect(areabuses{5},areabuses{8}) %find common states between the parent area and the child area
diffShared58 = mean(atan(temp101(numbus+sharedStates58,5)./temp101(sharedStates58,5))-...
    atan(temp101(numbus+sharedStates58,8)./temp101(sharedStates58,8))) % average delta theta between the two sets of states

diff458 = diffShared45+diffShared58
