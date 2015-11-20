% Time bus index vs find
findBusNum = numbus;

tic
busIndex = (1:numbus).';
m = busIndex(buses==findBusNum);
toc

tic
m = find(buses==findBusNum);
toc

