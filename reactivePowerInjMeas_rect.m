function [dQde, dQdf] = reactivePowerInjMeas_rect(e,f,G,B,numbus,buses,indQmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dQde = zeros(1,numbus);
dQdf = zeros(1,numbus);
busIndex = (1:numbus).';

for n = 1:numbus
    m = busIndex(buses==indQmeas(1,1));
    if m == n
        dQde(1,m) = -B(m,m)*e(m)+G(m,m)*f(m);
        for a = 1:numbus
            dQde(1,m) = dQde(1,m) + (-G(m,a)*f(a)-B(m,a)*e(a));
        end
        dQdf(1,m) = -G(m,m)*e(m)-B(m,m)*f(m);
        for b = 1:numbus
            dQdf(1,m) = dQdf(1,m) + (G(m,b)*e(b)-B(m,b)*f(b));
        end
    else
        dQde(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
        dQdf(1,n) = -G(m,n)*e(m)-B(m,n)*f(m);
    end
end