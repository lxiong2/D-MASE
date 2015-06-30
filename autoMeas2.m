% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

% Get rid of NaN so you can calculate gen - load
for a = 1:numbus
    if isnan(genMW(a))
        genMW(a) = 0;
    end
    if isnan(genMVAR(a))
        genMVAR(a) = 0;
    end
    if isnan(loadMW(a))
        loadMW(a) = 0;
    end
    if isnan(loadMVAR(a))
        loadMVAR(a) = 0;
    end
end

busMW = genMW - loadMW;
busMVAR = genMVAR - loadMVAR;

numMeas = cell(numParts,1);
allz = cell(numParts,1);
for a = 1:numParts
    numMeas{a} = size(allindices{a},1);
    allz{a} = getMeas(lines,numMeas{a},allindices{a},alltype{a},MWflows,MVARflows,revMWflows,revMVARflows,busV,busMW,busMVAR);
end