function [dV2de, dV2df] = vMeas_rect(e,f,numbus,buses,indVmeas)
% Elements of the measurement Jacobian H corresponding to
% voltage magnitude measurements

dV2de = zeros(1, numbus);
dV2df = zeros(1, numbus);
busIndex = (1:numbus).';

a = busIndex(buses==indVmeas(1,1));
dV2de(1,a) = 2*e(a);
dV2df(1,a) = 2*f(a);
