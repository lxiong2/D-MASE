function [dPijde, dPijdf] = realPowerFlowMeas_rect(e,f,G,B,numbus,buses,lines,indPFmeas)
% Elements of the measurement Jacobian H corresponding to
% real power flow measurements

dPijde = zeros(1, numbus);
dPijdf = zeros(1, numbus);
busIndex = (1:numbus).';

m = busIndex(buses==indPFmeas(1,1));
n = busIndex(buses==indPFmeas(1,2));
for b = 1:size(lines,1)
    dPijde(1,m) = -2*G(m,n)*e(m)+G(m,n)*e(n)-B(m,n)*f(n);
    dPijde(1,n) = G(m,n)*e(m)+B(m,n)*f(m);
    dPijdf(1,m) = -2*G(m,n)*f(m)+G(m,n)*f(n)+B(m,n)*e(n);
    dPijdf(1,n) = G(m,n)*f(m)-B(m,n)*e(m);
    
%     dPijde(1,m) = 2*G(m,m)*e(m)+(G(m,n)*e(n)-B(m,n)*f(n));
%     dPijde(1,n) = G(m,n)*e(m)+B(m,n)*f(m);
%     dPijdf(1,m) = 2*G(m,m)*f(m)+(G(m,n)*f(n)+B(m,n)*e(n));
%     dPijdf(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
end