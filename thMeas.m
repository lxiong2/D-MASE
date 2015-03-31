function [dthdth, dthdV] = thMeas(numbus,buses,indthmeas)
% Elements of the measurement Jacobian H corresponding to
% voltage magnitude measurements

dthdth = zeros(1, numbus);
dthdV = zeros(1, numbus);
busIndex = (1:numbus).';

a = busIndex(buses==indthmeas(1,1));
dthdth(1,a) = 1;
