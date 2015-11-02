inputnumber = 15;

sizecount = zeros(inputnumber,1);

for a = 1:numParts
    for b = 1:inputnumber
        if size(onlybuses{a},1)==b
            sizecount(b) = sizecount(b) + 1;
        end
    end
end
sizecount