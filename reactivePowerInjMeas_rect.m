function [dQde, dQdf] = reactivePowerInjMeas_rect(e,f,G,B,numbus,buses,indQmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dQde = zeros(1,size(buses,1));
dQdf = zeros(1,size(buses,1));
busIndex = (1:numbus).';

for a = 1:numbus
    m = busIndex(buses==indQmeas(1,1));
    if m == a
        dQde(1,m) = -B(m,m)*e(m)+G(m,m)*f(m);
        dQdf(1,m) = -G(m,m)*e(m)-B(m,m)*f(m);
        for b = 1:numbus % go through each adjacent bus
            dQde(1,m) = dQde(1,m) + (-G(m,b)*f(b)-B(m,b)*e(b));
            dQdf(1,m) = dQdf(1,m) + (G(m,b)*e(b)-B(m,b)*f(b));
        end
    else
        dQde(1,a) = -B(m,a)*e(m)+G(m,a)*f(m);
        dQdf(1,a) = -G(m,a)*e(m)-B(m,a)*f(m);
    end
end