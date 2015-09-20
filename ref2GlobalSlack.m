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
       
% %for a = 1:numParts
% for a = 1:1
%     a
%     for b = a+1:numParts
%         b
%         sharedStates = intersect(areabuses{a},areabuses{b}); % shared states between areas A and B
%         if isnan(sharedStates) == 0
%             diffShared = mean(atan(allStates(numbus+sharedStates,a)./allStates(sharedStates,a))-...
%                 atan(allStates(numbus+sharedStates,b)./allStates(sharedStates,b))); % average delta theta in the states
%             newStates(areabuses{a},a) = allStates(areabuses{a},a)*cos(diffShared/2)+...
%                 allStates(numbus+areabuses{a},a)*sin(diffShared/2); % adjust A's e states by half of the diff
%             newStates(numbus+areabuses{a},a) = allStates(numbus+areabuses{a},a)*cos(diffShared/2)-...
%                 allStates(areabuses{a},a)*sin(diffShared/2); % adjust A's f states by half of the diff
%             newStates(areabuses{b},b) = allStates(areabuses{b},b)*cos(diffShared/2)-...
%                 allStates(numbus+areabuses{b},b)*sin(diffShared/2); % adjust B's e states by half of the diff
%             newStates(numbus+areabuses{b},b) = allStates(numbus+areabuses{b},b)*cos(diffShared/2)+...
%                 allStates(areabuses{b},b)*sin(diffShared/2); % adjust B's f states by half of the diff
%             newStates
%             % for all other neighbors of A that are not equal to b
%             for c = 1:size(neighborAreas{a})
%                 c
%                 if neighborAreas{a}(c) ~= b
%                     neighborAreas{a}(c)
%                     newStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c)) = allStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*cos(diffShared/2)+...
%                         allStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*sin(diffShared/2);
%                     newStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c)) = allStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*cos(diffShared/2)-...
%                         allStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*sin(diffShared/2);
%                     newStates
%                 end
%             end
%             for d = 1:size(neighborAreas{b})
%                 d
%                 if neighborAreas{b}(d) ~= a
%                     neighborAreas{b}(d)
%                     newStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d)) = allStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*cos(diffShared/2)-...
%                         allStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*sin(diffShared/2);
%                     newStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d)) = allStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*cos(diffShared/2)+...
%                         allStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*sin(diffShared/2);
%                     newStates
%                 end
%             end
%         end     
%     end
%     allStates = newStates;
% end