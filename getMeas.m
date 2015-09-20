function [allz] = getMeas(buses,lines,numMeas,indices,type,MWflows,MVARflows,revMWflows,revMVARflows,busV,busMW,busMVAR)
allz = zeros(numMeas,1);
busIndex = (1:size(buses,1)).';
lineIndex = (1:size(lines,1)).';

for a = 1:numMeas
    if strcmp(type(a),'pf')
        temp = ismember(lines(:,1:3),indices(a,:),'rows');
        if sum(temp) ~= 0
            %indices(a,1:3)
            tempans = size(lineIndex(temp == 1));
            if tempans(1) > 1
                indices(a,1:3)
                lineIndex(temp == 1)
            end
            
            loc = lineIndex(temp == 1);
            allz(a) = MWflows(loc);
        else
            temp = ismember(lines(:,1:3),[indices(a,2) indices(a,1) indices(a,3)],'rows');
            loc = lineIndex(temp == 1);
            allz(a) = revMWflows(loc);
        end
    elseif strcmp(type(a),'qf')
        temp = ismember(lines(:,1:3),indices(a,:),'rows');
        if sum(temp) ~= 0
            loc = lineIndex(temp == 1);
            allz(a) = MVARflows(loc);
        else 
            temp = ismember(lines(:,1:3),[indices(a,2) indices(a,1) indices(a,3)],'rows');
            loc = lineIndex(temp == 1);
            allz(a) = revMVARflows(loc);
        end
    elseif strcmp(type(a),'p')
        allz(a) = busMW(busIndex(buses==indices(a,1)));
    elseif strcmp(type(a),'q')
        allz(a) = busMVAR(busIndex(buses==indices(a,1)));
    elseif strcmp(type(a),'v')
        allz(a) = busV(busIndex(buses==indices(a,1)));
    end
end