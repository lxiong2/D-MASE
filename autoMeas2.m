% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

simauto.RunScriptCommand('EnterMode(Run)');

fieldarray = {'BusNum','BusNum:1','LineCircuit','LineMW','LineMVR','LineMW:1','LineMVR:1'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
MWflows = str2double(results{2}{4})/100; 
MVARflows = str2double(results{2}{5})/100;
revMWflows = str2double(results{2}{6})/100;
revMVARflows = str2double(results{2}{7})/100;

fieldarray = {'BusNum','BusPUVolt','BusGenMW','BusGenMVR','BusLoadMW','BusLoadMVR'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('bus',fieldarray,'');
busV = str2double(results{2}{2}).^2; % need to square the bus voltages, since I'm using rectangular coordinates
genMW = str2double(results{2}{3})/100;
genMVAR = str2double(results{2}{4})/100;
loadMW = str2double(results{2}{5})/100;
loadMVAR = str2double(results{2}{6})/100;

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