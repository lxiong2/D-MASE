function [dth2de, dth2df] = thMeas_rect(numbus,buses,indthmeas)
% Elements of the measurement Jacobian H corresponding to
% voltage magnitude measurements

dth2de = zeros(1, numbus);
dth2df = zeros(1, numbus);
busIndex = (1:numbus).';

a = busIndex(buses==indthmeas(1,1));
dth2de(1,a) = ;
dth2df(1,a) = ;
