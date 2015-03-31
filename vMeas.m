function [dVdth dVdV] = vMeas(numbus,buses,indVmeas)
% Elements of the measurement Jacobian H corresponding to
% voltage magnitude measurements

dVdth = zeros(1, numbus);
dVdV = zeros(1, numbus);
busIndex = (1:numbus).';

a = busIndex(buses==indVmeas(1,1));
dVdV(1,a) = 1;
