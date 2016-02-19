% Generate Gaussian noise with mean = 0 and std = 0.01
noise = zeros(size(z,1),4);
for a = 1:size(z,1)
	%if (indices(a,1) ~= globalSlack) && (indices(a,2) ~= globalSlack)
        while (noise(a,4) > 0.03) || (noise(a,4) == 0)
            noise(a,:) = [indices(a,1:3) normrnd(0,0.01)];
        end
    %else noise(a,:) = [indices(a,1:3) 0];
    %end
end

% %% IEEE 14 bus case
% % Generate bad measurement of every type (first element of each type)
% noise(1,4) = 5; %pf
% noise(numlines+2,4) = 6; %qf
% noise(numlines*2+3,4) = 7; %p
% noise(numbus+numlines*2+4,4) = 8; %q
% noise(numbus*2+numlines*2+5,4) = 9; %v

%% Pensacola 42-bus case
% Generate bad measurement of every type (first element of each type)
noise(1,4) = 5; %pf
noise(numlines+18,4) = 6; %qf
noise(numlines*2+12,4) = 7; %p
noise(numbus+numlines*2+10,4) = 8; %q
noise(numbus*2+numlines*2+5,4) = 9; %v