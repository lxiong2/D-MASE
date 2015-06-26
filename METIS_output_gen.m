%% Overwrite the graph text file
fid = fopen('graph_partitions.txt','r');
numParts = 2;

for a = 1:numParts
    if 
    partitions(
end

% for a = 1:numbus
%     adjbuses = find(temp(a,:) ~= 0)
%     str = repmat('%d ',[1 size(adjbuses,2)])
%     fprintf(fid, str, adjbuses);
%     fprintf(fid, '\n');
% end

fid = fclose(fid);