numareas = 8;
G = neighborAreas;
v = 1;

distance = zeros(numareas,1);
parent = zeros(numareas,1);

for n = 1:numareas
    distance(n) = inf;
    parent(n) = 0;
end

newQ = CQueue();

distance(v) = 0;
newQ.push(v);

while newQ.isempty() == 0
    u = newQ.pop();
    for a = 1:size(neighborAreas{u},1)
        if distance(neighborAreas{u}(a)) == inf
            distance(neighborAreas{u}(a)) = distance(u)+1;
            parent(neighborAreas{u}(a)) = u;
            newQ.push(neighborAreas{u}(a));
        end
    end
end

