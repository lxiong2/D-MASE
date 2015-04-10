function [dth2de, dth2df] = thMeas_rect(e,f,numbus,buses,indthmeas)
% Elements of the measurement Jacobian H corresponding to
% voltage magnitude measurements

dth2de = zeros(1, numbus);
dth2df = zeros(1, numbus);
busIndex = (1:numbus).';

a = busIndex(buses==indthmeas(1,1));
% dth2de(1,a) = -2*f(a)*(atan(f(a)/e(a)))*1/(e(a)^2+f(a)^2);
% dth2df(1,a) = 2*atan(f(a)/e(a))*(e(a)/(e(a)^2+f(a)^2));

dth2de(1,a) = -f(a)/(e(a)^2+f(a)^2);
dth2df(1,a) = e(a)/(e(a)^2+f(a)^2);