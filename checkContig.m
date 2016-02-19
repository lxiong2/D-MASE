function [notContig,contigDistance,parent] = checkContig(whichPart,onlybuses,innerlines)
% See if you can get to each node in a partition by traversing its graph

sizeonlybus = size(onlybuses,1);
notContig = [];

% Create list of neighboring buses (actually bus indices for simplicity) based on inner lines
neighborBuses = cell(sizeonlybus,1);
adjBuses = unique(innerlines(:,1:2),'rows'); % [from bus area, to bus area]
onlybusIndex = (1:sizeonlybus).';
for a = 1:size(adjBuses,1)
    temp1 = onlybusIndex(adjBuses(a,1) == onlybuses);
    temp2 = onlybusIndex(adjBuses(a,2) == onlybuses);
    neighborBuses{temp1} = [neighborBuses{temp1}; temp2];
    neighborBuses{temp2} = [neighborBuses{temp2}; temp1];
end

% Start graph search with first bus of each partition
v = 1;
    
contigDistance = inf(sizeonlybus,1);
parent = zeros(sizeonlybus,1);

newQ = CQueue();

contigDistance(v) = 0;
newQ.push(v);

% breadth first search of each state's neighbors, using a queue
% implementation; uses CQueue, a C-like queue class that I got from
% Mathworks
while newQ.isempty() == 0
    u = newQ.pop();
    for b = 1:size(neighborBuses{u},1)
        if contigDistance(neighborBuses{u}(b)) == inf
            contigDistance(neighborBuses{u}(b))=contigDistance(u)+1; % distance is the cumulative difference in angle between areas
            parent(neighborBuses{u}(b)) = onlybuses(u);
            newQ.push(neighborBuses{u}(b));
        end
    end
end

% Find which buses cannot be reached from the first bus of the partition
notContig = [];
for a = 1:sizeonlybus
    if contigDistance(a) == inf
        notContig = [notContig; whichPart onlybuses(a)];
    end
end