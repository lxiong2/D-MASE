function [onlybuses,tiebuses,tielines] = getPartitions(numParts,buses,areas,numlines,lines,option)
% Option 1: manually enter which buses are in which area
% Option 2: automatically pull the area numbers from PowerWorld
% Option 3: use graph partitioner 

if option == 1
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

% Automatically get area numbers straight from PowerWorld
elseif option == 2
    % Get the actual area buses from PowerWorld
    onlybuses = cell(numParts,1);
    for a = 1:numParts
        [m,~] = find(areas == a);
        onlybuses{a} = buses(m);
    end
    % Look at each partition
    % What buses outside your area are connected to the buses in your area?
    % Those are the overlapping buses
    tiebuses = cell(numParts,1);
    for a = 1:numParts
        temptie = [];
        for b = 1:numlines
            % one end of the line has a bus in one partition, and the other
            % end of the line has a bus in a different partition, then you
            % know it's a tie line
            if sum(lines(b,1) == cell2mat(onlybuses(a))) == 1 && sum(lines(b,2) == cell2mat(onlybuses(a))) == 0
                temptie = [temptie; lines(b,2)];
            elseif sum(lines(b,2) == cell2mat(onlybuses(a))) == 1 && sum(lines(b,1) == cell2mat(onlybuses(a))) == 0
                temptie = [temptie; lines(b,1)];
            end
        end
        % Remove redundant buses from multiple lines
        tiebuses{a} = unique(temptie);
    end
    
% Use graph partitioner
elseif option == 3
    
end