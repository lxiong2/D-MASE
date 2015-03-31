function [dPdth, dPdV] = realPowerInjMeas(theta,V,G,B,numbus,buses,indPmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dPdth = zeros(1,numbus);
dPdV = zeros(1,numbus);
busIndex = (1:numbus).';

for n = 1:numbus
    m = busIndex(buses==indPmeas(1,1));
    if m == n
        dPdth(1,m) = -V(m)^2*B(m,m);
        for a = 1:numbus
            dPdth(1,m) = dPdth(1,m) + V(m)*V(a)*...
                (-G(m,a)*sin(theta(m)-theta(a))+...
                B(m,a)*cos(theta(m)-theta(a)));
        end
        dPdV(1,m) = V(m)*G(m,m);
        for b = 1:numbus
            dPdV(1,m) = dPdV(1,m) + V(b)*...
                (G(m,b)*cos(theta(m)-theta(b))+...
                B(m,b)*sin(theta(m)-theta(b)));
        end
    else
        dPdth(1,n) = V(m)*V(n)*(G(m,n)*...
            sin(theta(m)-theta(n))-B(m,n)*cos(theta(m)-theta(n)));
        dPdV(1,n) = V(m)*(G(m,n)*...
            cos(theta(m)-theta(n))+B(m,n)*sin(theta(m)-theta(n)));
    end
end