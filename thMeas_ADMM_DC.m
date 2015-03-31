function [dthdth] = thMeas_ADMM_DC(numbus,buses,allbuses_a,indthmeas)
% Elements of the measurement Jacobian H corresponding to
% voltage magnitude measurements

numbus_a = size(allbuses_a,1);
dthdth = zeros(1, numbus_a);
busIndex = (1:numbus).';
busIndex_a = (1:numbus_a).';

a = busIndex_a(allbuses_a==indthmeas(1,1));
dthdth(1,a) = 1;
