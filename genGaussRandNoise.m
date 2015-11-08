% Generate Gaussian noise with mean = 0 and std = 0.01
noise = zeros(size(z,1),4);
for a = 1:size(z,1)
	if (indices(a,1) ~= globalSlack) && (indices(a,2) ~= globalSlack)
        while (noise(a,4) > 0.03) || (noise(a,4) == 0)
            noise(a,:) = [indices(a,1:3) normrnd(0,0.01)];
        end
    else noise(a,:) = [indices(a,1:3) 0];
    end
end