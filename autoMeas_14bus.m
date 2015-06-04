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

numMeas1 = size(allindices1,1);
numMeas2 = size(allindices2,1);
numMeas3 = size(allindices3,1);
numMeas4 = size(allindices4,1);
allz1 = getMeas(lines,numMeas1,allindices1,alltype1,MWflows,MVARflows,revMWflows,revMVARflows,busV,busMW,busMVAR);
allz2 = getMeas(lines,numMeas2,allindices2,alltype2,MWflows,MVARflows,revMWflows,revMVARflows,busV,busMW,busMVAR);
allz3 = getMeas(lines,numMeas3,allindices3,alltype3,MWflows,MVARflows,revMWflows,revMVARflows,busV,busMW,busMVAR);
allz4 = getMeas(lines,numMeas4,allindices4,alltype4,MWflows,MVARflows,revMWflows,revMVARflows,busV,busMW,busMVAR);


