function [dPde, dPdf] = realPowerInjMeas_rect(e,f,G,B,numbus,buses,indPmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dPde = zeros(1,numbus);
dPdf = zeros(1,numbus);
busIndex = (1:numbus).';

for n = 1:numbus
    m = busIndex(buses==indPmeas(1,1));
    if m == n
        dPde(1,m) = B(m,m)*f(m);
        for a = 1:numbus
            dPde(1,m) = dPde(1,m)+(G(m,a)*e(a)-B(m,a)*f(a));
        end
        dPdf(1,m) = -B(m,m)*e(m);
        for b = 1:numbus
            dPdf(1,m) = dPdf(1,m)+(G(m,b)*f(b)+B(m,b)*e(b));
        end
    else
        dPde(1,n) = G(m,n)*e(m)+B(m,n)*f(m);
        dPdf(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
    end
end