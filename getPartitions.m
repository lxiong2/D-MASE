function [onlybuses,tiebuses,tielines,innerlines,globalSlackArea,areaconns,isContig] = getPartitions(numParts,buses,globalSlack,areas,numlines,lines,option,casename,filename)
%function [onlybuses,tiebuses,tielines,globalSlackArea,adjacentAreas] = getPartitions(numParts,buses,globalSlack,areas,numlines,lines,option,casename,filename)
% Option 1: manually enter which buses are in which area
% Option 2: automatically pull the area numbers from PowerWorld
% Option 3: use graph partitioner 

if option == 1
    if casename == 118
        % Manually enter which buses are in each area
        onlybuses = cell(numParts,1);
        tiebuses = cell(numParts,1);

        onlybuses{1} = [(1:23).'; (25:47).'; (48:59).'; (60:67).'; (113:115).'; 117];
        tiebuses{1} = [24; 68; 69];

        onlybuses{2} = [24; (68:112).'; 116; 118];
        tiebuses{2} = [23; 47; 49; 65];

        % Tie lines
        % 23 CollCrnr to 24 Trenton
        % 47 Crooksvl to 69 Sporn
        % 49 Philo to 69 Sporn
        % 65 Muskngum to 68 Sporn
        tielines{1} = [23 24 1 0.01350 0.04920 0.04980;
                       47 69 1 0.08440 0.27780 0.07092;
                       49 69 1 0.09850 0.32400 0.08280;
                       65 68 1 0.00138 0.01600 0.63800];
        tielines{2} = [23 24 1 0.01350 0.04920 0.04980;
                       47 69 1 0.08440 0.27780 0.07092;
                       49 69 1 0.09850 0.32400 0.08280;
                       65 68 1 0.00138 0.01600 0.63800];
    elseif casename == 14
        onlybuses = cell(numParts,1);
        tiebuses = cell(numParts,1);

        onlybuses{1} = [1; 2; 5];
        tiebuses{1} = [3; 4; 6];

        onlybuses{2} = [3; 4; 7; 8];
        tiebuses{2} = [2; 5; 9];
        
        onlybuses{3} = [6; 11; 12; 13];
        tiebuses{3} = [5; 10; 14];
        
        onlybuses{4} = [9; 10; 14];
        tiebuses{4} = [4; 7; 11; 13];

        % Tie lines
        % 23 CollCrnr to 24 Trenton
        % 47 Crooksvl to 69 Sporn
        % 49 Philo to 69 Sporn
        % 65 Muskngum to 68 Sporn
        temptielines = [2 3 1 0.02 0.05 0.0438;
                    2 3 2 0.02 0.05 0.0438;
                    2 4 1 0.05811 0.17632 0.034;
                    4 5 1 0.01335 0.04211 0;
                    4 9 1 0 0.55618 0;
                    5 6 1 0 0.25202 0;
                    7 9 1 0 0.11001 0;
                    10 11 1 0.08205 0.19207 0;
                    13 14 1 0.17093 0.34802 0];

        tielines{1} = [temptielines(1,:);
                       temptielines(2,:);
                       temptielines(3,:);
                       temptielines(4,:);
                       temptielines(6,:)];

        tielines{2} = [temptielines(1,:);
                       temptielines(2,:);
                       temptielines(4,:);
                       temptielines(5,:);
                       temptielines(7,:)];

        tielines{3} = [temptielines(6,:);
                       temptielines(8,:);
                       temptielines(9,:)];

        tielines{4} = [temptielines(5,:);
                       temptielines(7,:);
                       temptielines(8,:);
                       temptielines(9,:)];
    end
    
    % Automatically identify the global slack area
    % i.e. whichever area's state vector contains bus 1
    globalSlackArea = 0;
    for a = 1:numParts
        if sum(onlybuses{a} == 1)
            globalSlackArea = a;
        end
    end

% Automatically get area numbers straight from entered PowerWorld area
% field
elseif option == 2
    
    arealist = unique(areas);
    
    % Get the actual area buses from PowerWorld
    onlybuses = cell(numParts,1);
    for a = 1:numParts
        [m,~] = find(areas == arealist(a));
        onlybuses{a} = buses(m);
    end
    % Look at each partition
    % What buses outside your area are connected to the buses in your area?
    % Those are the overlapping buses
    tiebuses = cell(numParts,1);
    tielines = cell(numParts,1);

    for a = 1:numParts
        temptie = [];
        temptieIndex = [];
        temptieline = [];
        for b = 1:numlines
            % one end of the line has a bus in one partition, and the other
            % end of the line has a bus in a different partition, then you
            % know it's a tie line
            if sum(lines(b,1) == cell2mat(onlybuses(a))) == 1 && sum(lines(b,2) == cell2mat(onlybuses(a))) == 0
                temptie = [temptie; lines(b,2)];
                temptieline = [temptieline; lines(b,:)];
            elseif sum(lines(b,2) == cell2mat(onlybuses(a))) == 1 && sum(lines(b,1) == cell2mat(onlybuses(a))) == 0
                temptie = [temptie; lines(b,1)];
                temptieline = [temptieline; lines(b,:)];
            end
        end
        % Remove redundant buses from multiple lines
        tiebuses{a} = unique(temptie);
        tielines{a} = temptieline;
    end
    
    % Automatically identify the global slack area
    % i.e. whichever area's state vector contains bus 1
    globalSlackArea = 0;
    for a = 1:numParts
        if sum(onlybuses{a} == globalSlack)
            globalSlackArea = a;
        end
    end

% Use graph partitioner
elseif option == 3
   
    % NOTE: DELETE LAST BLANK LINE IN TEXT FILE
    METIS_out = dlmread(filename,'\n').';   % CHANGE THIS DEPENDING ON THE CASE

    onlybuses = cell(numParts,1);
    for a = 1:numParts
        onlybuses{a} = find(METIS_out == (a-1)); % METIS output starts from 0
    end
  
    % COPIED FROM OPTION 2
    % Look at each partition
    % What buses outside your area are connected to the buses in your area?
    % Those are the overlapping buses
    tiebuses = cell(numParts,1);
    tielines = cell(numParts,1);
    innerlines = cell(numParts,1);
    for a = 1:numParts
        temptie = [];
        temptieline = [];
        tempinnerline = [];
        for b = 1:numlines
            % one end of the line has a bus in one partition, and the other
            % end of the line has a bus in a different partition, then you
            % know it's a tie line
            if sum(lines(b,1) == cell2mat(onlybuses(a))) == 1 && sum(lines(b,2) == cell2mat(onlybuses(a))) == 0
                temptie = [temptie; lines(b,2)];
                temptieline = [temptieline; lines(b,:)];
            elseif sum(lines(b,2) == cell2mat(onlybuses(a))) == 1 && sum(lines(b,1) == cell2mat(onlybuses(a))) == 0
                temptie = [temptie; lines(b,1)];
                temptieline = [temptieline; lines(b,:)];
            elseif sum(lines(b,1) == cell2mat(onlybuses(a))) == 1 && sum(lines(b,2) == cell2mat(onlybuses(a))) == 1
                tempinnerline = [tempinnerline; lines(b,:)];
            end
        end
        % Remove redundant buses from multiple lines
        tiebuses{a} = unique(temptie);
        tielines{a} = temptieline;
        innerlines{a} = tempinnerline;
    end
    
    % Automatically identify the global slack area
    % i.e. whichever area's state vector contains bus 1
    globalSlackArea = 0;
    for a = 1:numParts
        if sum(onlybuses{a} == 1)
            globalSlackArea = a;
        end
    end
end

% Create a table of area connections
areaconns = [];
for a = 1:numParts
    for b = 1:numParts
        for c = 1:numlines
            if a~=b && sum(lines(c,1) == cell2mat(onlybuses(a))) == 1 && sum(lines(c,2) == cell2mat(onlybuses(b))) == 1
                areaconns = [areaconns; a b lines(c,:)];
            end
        end
    end
end