function [dQijde, dQijdf] = reactivePowerFlowMeas_rect(e,f,G,B,numbus,buses,lines,indQFmeas)
% Elements of the measurement Jacobian H corresponding to
% reactive power flow measurements

dQijde = zeros(1, numbus);
dQijdf = zeros(1, numbus);
busIndex = (1:numbus).';

m = busIndex(buses==indQFmeas(1,1));
n = busIndex(buses==indQFmeas(1,2));
for b = 1:size(lines,1)
    dQijde(1,m) = -2*B(m,m)*e(m)+(-G(m,n)*f(n)-B(m,n)*e(n));
    dQijde(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
    dQijdf(1,m) = -2*B(m,m)*f(m)+(G(m,n)*e(n)-B(m,n)*f(n));
    dQijdf(1,n) = -G(m,n)*e(m)-B(m,n)*f(m);
end