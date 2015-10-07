function [newStates,polarStates,distance,parent] = ref2GlobalSlack(allStates,numbus,numParts,areabuses,neighborAreas,globalSlackArea)
% Assumes each area knows its neighboring areas
% Remember that states are in polar coordinates

% Assume allStates are provided with respect to the global index, i.e.
% size(allStates) = numbus*2 x numParts

newStates = zeros(size(allStates,1),size(allStates,2));
%newStates = allStates;

v = globalSlackArea;
    
distance = inf(numParts,1); %difference in slack angle between each parent node and its children
parent = zeros(numParts,1);

newQ = CQueue();

distance(v) = 0;
newQ.push(v);

newStates(areabuses{v},v) = allStates(areabuses{v},v);
newStates(numbus+areabuses{v},v) = allStates(numbus+areabuses{v},v);

% breadth first search of each state's neighbors, using a queue
% implementation; uses CQueue, a C-like queue class that I got from
% Mathworks
while newQ.isempty() == 0
    u = newQ.pop();
    for b = 1:size(neighborAreas{u},1)
        sharedStates = intersect(areabuses{u},areabuses{neighborAreas{u}(b)});
        if isnan(sharedStates) == 0
            diffShared = mean(atan(allStates(numbus+sharedStates,u)./allStates(sharedStates,u))-...
                atan(allStates(numbus+sharedStates,neighborAreas{u}(b))./allStates(sharedStates,neighborAreas{u}(b)))); % average delta theta in the states    
        else display('Error with neighborAreas');
        end
        if distance(neighborAreas{u}(b)) == inf
            distance(neighborAreas{u}(b))=distance(u)+diffShared;    
            newStates(areabuses{neighborAreas{u}(b)},neighborAreas{u}(b)) = allStates(areabuses{neighborAreas{u}(b)},neighborAreas{u}(b))*cos(distance(neighborAreas{u}(b)))-...
                allStates(numbus+areabuses{neighborAreas{u}(b)},neighborAreas{u}(b))*sin(distance(neighborAreas{u}(b)));
            newStates(numbus+areabuses{neighborAreas{u}(b)},neighborAreas{u}(b)) = allStates(numbus+areabuses{neighborAreas{u}(b)},neighborAreas{u}(b))*cos(distance(neighborAreas{u}(b)))+...
                allStates(areabuses{neighborAreas{u}(b)},neighborAreas{u}(b))*sin(distance(neighborAreas{u}(b)));
            parent(neighborAreas{u}(b)) = u;
            newQ.push(neighborAreas{u}(b));
        end
    end
end

polarStates = convertRect2Polar(newStates, numParts, numbus);
