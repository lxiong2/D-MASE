function [dV2de, dV2df] = vMeas_rectADMM(e,f,buses_a,indVmeas)
% Elements of the measurement Jacobian H corresponding to
% voltage magnitude measurements

dV2de = zeros(1,size(buses_a,1));
dV2df = zeros(1,size(buses_a,1));
busIndex_a = (1:size(buses_a,1)).';

a = busIndex_a(buses_a==indVmeas(1,1));
dV2de(1,a) = 2*e(a);
dV2df(1,a) = 2*f(a);
