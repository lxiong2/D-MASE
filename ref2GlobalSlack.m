function [newStates,polarStates] = ref2GlobalSlack(allStates,numbus,numParts,areabuses,neighborAreas)
% Assumes each area knows its neighboring areas
% Remember that states are in polar coordinates

% Assume allStates are provided with respect to the global index, i.e.
% size(allStates) = numbus*2 x numareas

newStates = zeros(size(allStates,1),size(allStates,2));
busIndex = (1:numbus).';

% Look at overlapping areas
% for a = 1:numParts
% %for a = 1:2
%     a
%     for b = 1:size(neighborAreas{a},1)
%     %for b = 1:1
%         display('Area B')
%         neighborAreas{a}(b)
%         sharedStates = intersect(areabuses{a},areabuses{neighborAreas{a}(b)}) % shared states between areas A and B
%         diffShared = mean(atan(allStates(numbus+sharedStates,a)./allStates(sharedStates,a))-...
%             atan(allStates(numbus+sharedStates,neighborAreas{a}(b))./allStates(sharedStates,neighborAreas{a}(b)))) % average delta theta in the states
%         newStates(areabuses{a},a) = allStates(areabuses{a},a)*cos(diffShared/2)+allStates(numbus+areabuses{a},a)*sin(diffShared/2); % adjust A's e states by half of the diff
%         newStates(numbus+areabuses{a},a) = allStates(numbus+areabuses{a},a)*cos(diffShared/2)-allStates(areabuses{a},a)*sin(diffShared/2); % adjust A's f states by half of the diff
%         newStates(areabuses{neighborAreas{a}(b)},neighborAreas{a}(b)) = allStates(areabuses{neighborAreas{a}(b)},neighborAreas{a}(b))*cos(diffShared/2)-...
%             allStates(numbus+areabuses{neighborAreas{a}(b)},neighborAreas{a}(b))*sin(diffShared/2);
%         newStates(numbus+areabuses{neighborAreas{a}(b)},neighborAreas{a}(b)) = allStates(numbus+areabuses{neighborAreas{a}(b)},neighborAreas{a}(b))*cos(diffShared/2)+...
%             allStates(areabuses{neighborAreas{a}(b)},neighborAreas{a}(b))*sin(diffShared/2);
%         newStates
%         % for all other neighbors of A that are not equal to b
%         for c = 1:size(neighborAreas{a})
%             if neighborAreas{a}(c) ~= b
%                 display('neighbor of A')
%                 neighborAreas{b}(c)
%                 newStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c)) = allStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*cos(diffShared/2)+...
%                     allStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*sin(diffShared/2);
%                 newStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c)) = allStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*cos(diffShared/2)-...
%                     allStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*sin(diffShared/2);
%                 newStates
%             end
%         end
%         for d = 1:size(neighborAreas{b})
%             if neighborAreas{b}(d) ~= a
%                 display('neighbor of B')
%                 d
%                 neighborAreas{b}(d)
%                 newStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d)) = allStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*cos(diffShared/2)-...
%                     allStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*sin(diffShared/2);
%                 newStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d)) = allStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*cos(diffShared/2)+...
%                     allStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*sin(diffShared/2);
%                 newStates
%             end
%         end
%         
%     end
%     allStates = newStates;
% end

for a = 1:numParts
    for b = a+1:numParts
        sharedStates = intersect(areabuses{a},areabuses{b}); % shared states between areas A and B
        if isnan(sharedStates) == 0
            diffShared = mean(atan(allStates(numbus+sharedStates,a)./allStates(sharedStates,a))-...
                atan(allStates(numbus+sharedStates,b)./allStates(sharedStates,b))); % average delta theta in the states
            newStates(areabuses{a},a) = allStates(areabuses{a},a)*cos(diffShared/2)+...
                allStates(numbus+areabuses{a},a)*sin(diffShared/2); % adjust A's e states by half of the diff
            newStates(numbus+areabuses{a},a) = allStates(numbus+areabuses{a},a)*cos(diffShared/2)-...
                allStates(areabuses{a},a)*sin(diffShared/2); % adjust A's f states by half of the diff
            newStates(areabuses{b},b) = allStates(areabuses{b},b)*cos(diffShared/2)-...
                allStates(numbus+areabuses{b},b)*sin(diffShared/2); % adjust B's e states by half of the diff
            newStates(numbus+areabuses{b},b) = allStates(numbus+areabuses{b},b)*cos(diffShared/2)+...
                allStates(areabuses{b},b)*sin(diffShared/2); % adjust B's f states by half of the diff
            % for all other neighbors of A that are not equal to b
            for c = 1:size(neighborAreas{a})
                if neighborAreas{a}(c) ~= b
                    newStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c)) = allStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*cos(diffShared/2)+...
                        allStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*sin(diffShared/2);
                    newStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c)) = allStates(numbus+areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*cos(diffShared/2)-...
                        allStates(areabuses{neighborAreas{a}(c)},neighborAreas{a}(c))*sin(diffShared/2);
                end
            end
            for d = 1:size(neighborAreas{b})
                if neighborAreas{b}(d) ~= a
                    newStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d)) = allStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*cos(diffShared/2)-...
                        allStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*sin(diffShared/2);
                    newStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d)) = allStates(numbus+areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*cos(diffShared/2)+...
                        allStates(areabuses{neighborAreas{b}(d)},neighborAreas{b}(d))*sin(diffShared/2);
                end
            end
        end     
    end
    allStates = newStates;
end


% Convert allStates back to polar coordinates for debug purposes
for b = 1:numParts
    for a = 1:numbus
        polarStates(a,b) = atan(allStates(numbus+a,b)/allStates(a,b));
        if isnan(polarStates(a,b)) == 1
            polarStates(a,b) = 0;
        end
        polarStates(numbus+a,b) = sqrt(allStates(a,b)^2+allStates(numbus+a,b)^2);
    end
end
    
% for a = 1:numParts
%     for b = a+1:numParts
%         b
%         if a ~= b
%             if isempty(intersect(areabuses{a},areabuses{b}))==0 %
%                 for c = 1:size(intersect(areabuses{a},areabuses{b}),1)
%                     conns = intersect(areabuses{a},areabuses{b})
%                     newStates(areabuses{a},a) = allStates(areabuses{a},a)-(allStates(conns(c),a)-allStates(conns(c),b))/2;
%                     newStates(areabuses{b},b) = allStates(areabuses{b},b)+(allStates(conns(c),a)-allStates(conns(c),b))/2;
%                     newStates
%                     % Also subtract from neighboring areas of A
%                     for d = 1:size(neighborAreas{a})
%                         if neighborAreas{a}(d) ~= b
%                             d
%                             newStates(areabuses{neighborAreas{a}(d)},neighborAreas{a}(d)) = allStates(areabuses{neighborAreas{a}(d)},neighborAreas{a}(d))-(allStates(conns(c),a)-allStates(conns(c),b))/2
%                         end
%                     end
%                     % Also add to neighboring areas of B
%                     for e = 1:size(neighborAreas{b})
%                         if neighborAreas{b}(e) ~= a
%                             e
%                             newStates(areabuses{neighborAreas{b}(e)},neighborAreas{b}(e)) = allStates(areabuses{neighborAreas{b}(e)},neighborAreas{b}(e))+(allStates(conns(c),a)-allStates(conns(c),b))/2
%                         end
%                     end
%                 end
%                 allStates = newStates
%             end
%         end
%     end
% end
