function [z] = getMeas(lines,indices,meastype,MWflows,MVARflows,revMWflows,revMVARflows)
numlines = size(lines,1);
z = zeros(numlines,1);
lineIndex = (1:numlines).';

if strcmp(meastype,'pf')
    for a = 1:numlines
        temp = ismember(lines(:,1:3),indices(a,:),'rows');
        if sum(temp) ~= 0           
            loc = lineIndex(temp == 1);
            z(a) = MWflows(loc);
        else
            temp = ismember(lines(:,1:3),[indices(a,2) indices(a,1) indices(a,3)],'rows');
            loc = lineIndex(temp == 1);
            z(a) = revMWflows(loc);
        end
    end
elseif strcmp(meastype,'qf')
    for a = 1:numlines
        temp = ismember(lines(:,1:3),indices(a,:),'rows');
        if sum(temp) ~= 0
            loc = lineIndex(temp == 1);
            z(a) = MVARflows(loc);
        else 
            temp = ismember(lines(:,1:3),[indices(a,2) indices(a,1) indices(a,3)],'rows');
            loc = lineIndex(temp == 1);
            z(a) = revMVARflows(loc);
        end
    end
end