globalStates = zeros(numbus*2,numParts);
for a = 1:numParts
    globalStates(areabuses{a},a) = x_k{a}(1:numareabus{a},iter);
    globalStates(numbus+areabuses{a},a) = x_k{a}(numareabus{a}+1:numareabus{a}*2,iter);
end