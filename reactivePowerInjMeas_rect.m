function [dQde, dQdf] = reactivePowerInjMeas_rect(e,f,G,B,numbus,buses,adjbuses,indQmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dQde = zeros(1,size(buses,1));
dQdf = zeros(1,size(buses,1));

for a = 1:numbus
    m = find(buses==indQmeas(1,1));
    if m == a
        dQde(1,m) = -B(m,m)*e(m)+G(m,m)*f(m);
        dQdf(1,m) = -G(m,m)*e(m)-B(m,m)*f(m);
        for n = 1:size(adjbuses{m},2) % go through each adjacent bus
            b = adjbuses{m}(n);
            dQde(1,m) = dQde(1,m) + (-G(m,b)*f(b)-B(m,b)*e(b));
            dQdf(1,m) = dQdf(1,m) + (G(m,b)*e(b)-B(m,b)*f(b));
        end
    else
        dQde(1,a) = -B(m,a)*e(m)+G(m,a)*f(m);
        dQdf(1,a) = -G(m,a)*e(m)-B(m,a)*f(m);
    end
end