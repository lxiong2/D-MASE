function [dPdth] = realPowerInjMeas_DC2(theta,V,G,B,numbus,buses,indPmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dPdth = zeros(1,numbus);
busIndex = (1:numbus).';

for n = 1:numbus
    m = busIndex(buses==indPmeas(1,1));
    if m == n
        dPdth(1,m) = -V(m)^2*B(m,m);
        for a = 1:numbus
            dPdth(1,m) = dPdth(1,m) + V(m)*V(a)*...
                (-G(m,a)*(theta(m)-theta(a))+...
                B(m,a)*(1-(theta(m)-theta(a))^2/2));
        end
    else
        dPdth(1,n) = V(m)*V(n)*(G(m,n)*...
            (theta(m)-theta(n))-B(m,n)*(1-(theta(m)-theta(n))^2/2));
    end
end