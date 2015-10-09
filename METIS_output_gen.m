%% Overwrite the graph text file
numParts = 2;
METIS_out = dlmread('graph14_2parts.txt','\n');

onlybuses = cell(numParts,1);
for a = 1:numParts
    onlybuses{a} = find(METIS_out == (a-1));
end