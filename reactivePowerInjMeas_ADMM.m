function [dQdth, dQdV] = reactivePowerInjMeas_ADMM(theta,V,G,B,numbus,buses,indQmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dQdth = zeros(1,numbus);
dQdV = zeros(1,numbus);
busIndex = (1:numbus).';

for n = 1:numbus
    m = busIndex(buses==indQmeas(1,1));
    if m == n
        dQdth(1,m) = -V(m)^2*G(m,m);
        for a = 1:numbus
            dQdth(1,m) = dQdth(1,m) + V(m)*V(a)*...
                (G(m,a)*cos(theta(m)-theta(a))+...
                B(m,a)*sin(theta(m)-theta(a)));
        end
        dQdV(1,m) = -V(m)*B(m,m);
        for b = 1:numbus
            dQdV(1,m) = dQdV(1,m) + V(b)*...
                (G(m,b)*sin(theta(m)-theta(b))-...
                B(m,b)*cos(theta(m)-theta(b)));
        end
    else
        dQdth(1,n) = V(m)*V(n)*(-G(m,n)*...
            cos(theta(m)-theta(n))-B(m,n)*sin(theta(m)-theta(n)));
        dQdV(1,n) = V(m)*(G(m,n)*...
            sin(theta(m)-theta(n))-B(m,n)*cos(theta(m)-theta(n)));
    end
end