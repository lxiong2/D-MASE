% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus_doublelines.pwb';
% filename = 'graph14_4parts.txt'; % only matters if option = 3
% numParts = 4; % should match filename if option = 3
% numbus = 14;

casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 57 bus.pwb';
filename = 'graph57_8parts.txt'; % only matters if option = 3
numParts = 8;
numbus = 57;

% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_2parts.pwb';
% filename = 'graph118_4parts.txt'; % only matters if option = 3
% numParts = 4; % should match filename if option = 3
% numbus = 118;

% Read METIS file
% NOTE: DELETE LAST BLANK LINE IN TEXT FILE
METIS_out = dlmread(filename,'\n').';   % CHANGE THIS DEPENDING ON THE CASE

onlybuses = cell(numParts,1);
for a = 1:numParts
    onlybuses{a} = find(METIS_out == (a-1)); % METIS output starts from 0
end

areanum = zeros(numbus,1);
for a = 1:numParts
    for b = 1:size(onlybuses{a},1)
        areanum(onlybuses{a}(b)) = a;
    end
end

simauto = actxserver('pwrworld.SimulatorAuto');

% NOTE: Check case file path before running
simauto.OpenCase(casepath)

% Change the area numbers automatically in the PowerWorld case
for a = 1:numbus
    str = sprintf('SetData(Bus,[BusNum,AreaNum],[%d,%d]);',a,areanum(a,1));
    simauto.RunScriptCommand(str);
end

simauto.SaveCase(casepath,'PWB',true);
simauto.CloseCase();
delete(simauto);