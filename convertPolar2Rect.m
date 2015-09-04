function [rectStates] = convertPolar2Rect(polarStates, numParts, numbus)
% Convert allStates from polar to rectangular coordinates for debug purposes

rectStates = zeros(size(polarStates,1),size(polarStates,2));

for b = 1:numParts
    for a = 1:numbus
        rectStates(a,b) = polarStates(numbus+a,b)*cos(polarStates(a,b));
        rectStates(numbus+a,b) = polarStates(numbus+a,b)*sin(polarStates(a,b));
    end
end
    
    
