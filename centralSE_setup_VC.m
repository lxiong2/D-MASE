% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% % NOTE: Delete the blank line at the end of graph_XXX.txt
% filename = 'graph118_4parts.txt'; % only matters if option = 3
% numParts = 4; % should match filename if option = 3
% casename = 118;

simauto = actxserver('pwrworld.SimulatorAuto');

% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

% NOTE: Check case file path before running
simauto.OpenCase(casepath)

% Automatically save Ybus
%simauto.RunScriptCommand('SaveYbusInMatlabFormat("C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\YBus14.m",NO)');

simauto.RunScriptCommand('EnterMode(Run)');

% Run rectangular Newton-Raphson power flow
simauto.RunScriptCommand('SolvePowerFlow(RECTNEWT,,,,)');

% Get the slack bus number
%globalSlack = buses(strcmp(results{2}{2},'YES'));
globalSlack = 1;
globalSlackIndex = 1;

% Get the list of buses in the system
fieldarray = {'BusNum','BusSlack','AreaNum','BusRad','BusPUVolt','BusSlack'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('bus',fieldarray,'');
buses = str2double(results{2}{1});
%tempbuses = str2double(results{2}{1});
%buses = size
numbus = size(buses,1);
areas = str2double(results{2}{3});
centralPWStates_th = str2double(results{2}{4});
centralPWStates_V = str2double(results{2}{5});
centralPWStates = [centralPWStates_th - centralPWStates_th(globalSlackIndex); centralPWStates_V];

%% Line Information
% Get line parameters for full AC system
fieldarray = {'BusNum','BusNum:1','LineCircuit','LineR','LineX','LineC'}; %at from bus, at to bus
results = simauto.GetParametersMultipleElement('branch',fieldarray,'');
lines = [str2double(results{2}{1}) str2double(results{2}{2}) str2double(results{2}{3})...
         str2double(results{2}{4}) str2double(results{2}{5}) str2double(results{2}{6})];
numlines = size(lines,1);

% If circuit number is EQ or E2, then convert them to 100, 101, etc.
% respectively
lineCheck = [0 0];
for a = 1:numlines
    % if it's the first time that a line has NaN in the circuit number field,
    % then just assign 100, and put it into this checklist
    %(isnan(lines(a,3)) == 1)
    inLineCheck = sum(ismember(lineCheck,lines(a,1:2),'rows'));
    if (isnan(lines(a,3)) == 1) && (inLineCheck == 0)
        lines(a,3) = 100;
        lineCheck = [lineCheck; lines(a,1:2)];
    % isnan(lines(a,3)) == 1 && sum(ismember(lineCheck,lines(a,1:3)))==0
    elseif (isnan(lines(a,3)) == 1) && (inLineCheck > 0)
        lines(a,3) = 100 + inLineCheck;
        lineCheck = [lineCheck; lines(a,1:2)];
    end
end

% % Get the list of transformers in the system
% fieldarray = {'BusNum','BusNum:1','LineCircuit','LineTap','LinePhase'}; %at from bus, at to bus
% results = simauto.GetParametersMultipleElement('transformer',fieldarray,'');
% xfmrs = [str2double(results{2}{1}) str2double(results{2}{2}) str2double(results{2}{3})...
%          str2double(results{2}{4}) str2double(results{2}{5})];
% numxfmrs = size(lines,1);

% list of adjacent buses
% NOTE: preset the size of adjbuses to be 15, may need to change that for
% larger cases
temp = zeros(numbus,numbus);
linesCol1 = zeros(numbus,1);
linesCol2 = zeros(numbus,1);
for a = 1:numlines
    %temp(lines(a,1),lines(a,2)) = temp(lines(a,1),lines(a,2))+1;
    %temp(lines(a,2),lines(a,1)) = temp(lines(a,2),lines(a,1))+1;
%   temp(find(lines(:,1)==lines(a,1)),find(lines(:,1)==lines(a,2))) = temp(find(lines(:,1)==lines(a,1)),find(lines(:,1)==lines(a,2))) + 1;
%   temp(find(lines(:,1)==lines(a,2)),find(lines(:,1)==lines(a,1))) = temp(find(lines(:,1)==lines(a,2)),find(lines(:,1)==lines(a,1))) + 1;
    linesCol1(a,1) = lines(a,1);
    linesCol2(a,1) = lines(a,2);
    temp(find(linesCol1(a,1)),find(linesCol2(a,1))) = temp(find(linesCol1(a,1)),find(linesCol2(a,1))) + 1;
    temp(find(linesCol2(a,1)),find(linesCol1(a,1))) = temp(find(linesCol2(a,1)),find(linesCol1(a,1))) + 1;
    linesCol1 = zeros(numbus,1);
    linesCol2 = zeros(numbus,1);
    
end

adjbuses = cell(numbus,1);
for a = 1:numbus
    temp2 = find(temp(a,:) ~= 0);
    adjbuses{a} = [a temp2];
end
%adjbuses = [(1:numbus).' adjbuses];
            
% Get power flow line results
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

simauto.CloseCase();
delete(simauto);

%% Full measurement information from PowerWorld AC power flow results

% Autogenerate the type, indices, and R
% matrices
  
type = [repmat({'pf'}, [numlines 1]);
        repmat({'qf'}, [numlines 1]);
        repmat({'p'}, [numbus 1]);
        repmat({'q'}, [numbus 1]);
        repmat({'v'}, [numbus 1])];

numtype = [numlines; numlines; numbus; numbus; numbus];
    
R = diag(0.01^2*ones(1,size(type,1)));

% FIX: Need to include those boundary measurements
indices = zeros(2*numlines+3*numbus,3);
indices(1:numlines,:) = lines(:,1:3);
indices(numlines+1:2*numlines,:) = lines(:,1:3);
indices((2*numlines+1):(2*numlines+numbus),1) = buses(:,1);
indices((2*numlines+numbus+1):(2*numlines+2*numbus),1) = buses(:,1);
indices((2*numlines+2*numbus+1):(2*numlines+3*numbus),1) = buses(:,1);

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

% Get measurements
z = zeros(2*numlines+3*numbus,1);
z(1:numlines,1) = getMeas(lines,indices,'pf',MWflows,MVARflows,revMWflows,revMVARflows);
z(numlines+1:2*numlines,1) = getMeas(lines,indices,'qf',MWflows,MVARflows,revMWflows,revMVARflows);
z((2*numlines+1):(2*numlines+numbus),1) = busMW;
z((2*numlines+numbus+1):(2*numlines+2*numbus),1) = busMVAR;
z((2*numlines+2*numbus+1):(2*numlines+3*numbus),1) = busV;

% Identify parallel lines
paraLines = zeros(numlines,1);
for a = 1:numlines
    if lines(a,3) > 1
        paraLines(a) = 1;
        temp = intersect(find(lines(:,1)==indices(a,1)),find(lines(:,2)==indices(a,2)));
        temp2 = intersect(find(lines(:,2)==indices(a,1)),find(lines(:,1)==indices(a,2)));
        paraLines(temp) = 1;
        paraLines(temp2) = 1;
    end
end
paraLineIndex = find(paraLines~=0); % find the line indices of parallel branches