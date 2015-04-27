function [dPde, dPdf] = realPowerInjMeas_rect(e,f,G,B,numbus,buses,indPmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dPde = zeros(1,size(buses,1));
dPdf = zeros(1,size(buses,1));
busIndex = (1:numbus).';

for a = 1:numbus
    m = busIndex(buses==indPmeas(1,1));
    if m == a
        dPde(1,m) = G(m,m)*e(m)+B(m,m)*f(m);
        dPdf(1,m) = -B(m,m)*e(m)+G(m,m)*f(m);
        for b = 1:numbus % go through each adjacent bus
            dPde(1,m) = dPde(1,m)+(G(m,b)*e(b)-B(m,b)*f(b));
            dPdf(1,m) = dPdf(1,m)+(G(m,b)*f(b)+B(m,b)*e(b));
        end
    else
        dPde(1,a) = G(m,a)*e(m)+B(m,a)*f(m);
        dPdf(1,a) = -B(m,a)*e(m)+G(m,a)*f(m);
    end
end