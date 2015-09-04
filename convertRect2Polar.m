function [polarStates] = convertRect2Polar(rectStates, numParts, numbus)
% Convert allStates back to polar coordinates for debug purposes
polarStates = zeros(size(rectStates,1),size(rectStates,2));

for b = 1:numParts
    for a = 1:numbus
        polarStates(a,b) = atan(rectStates(numbus+a,b)/rectStates(a,b));
        if isnan(polarStates(a,b)) == 1
            polarStates(a,b) = 0;
        end
        polarStates(numbus+a,b) = sqrt(rectStates(a,b)^2+rectStates(numbus+a,b)^2);
    end
end
    
    
