function [dPdth] = realPowerInjMeas_ADMM_DC(theta,V,G,B,numbus,buses,allbuses_a,adjbuses,indPmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

numbus_a = size(allbuses_a,1);
dPdth = zeros(1,numbus_a);
dPdV = zeros(1,numbus_a);
busIndex = (1:numbus).';
busIndex_a = (1:numbus_a).';

for n_a = 1:numbus_a
    m = busIndex(buses==indPmeas(1,1));
    m_a = busIndex_a(allbuses_a==indPmeas(1,1));
    n = allbuses_a(n_a);
    if m == n
        dPdth(1,m_a) = -V(m_a)^2*B(m,m);
        for d = 1:size(adjbuses(1,:))
            a = adjbuses(m,d);
            a_a = busIndex_a(allbuses_a==adjbuses(m,d));
            dPdth(1,m_a) = dPdth(1,m_a) + V(m_a)*V(a_a)*...
                (-G(m,a)*(theta(m_a)-theta(a_a))+...
                B(m,a)*(1-(theta(m_a)-theta(a_a))^2/2));
        end
    else
        dPdth(1,n_a) = V(m_a)*V(n_a)*(G(m,n)*...
            (theta(m_a)-theta(n_a))-B(m,n)*(1-(theta(m_a)-theta(n_a))^2/2));
    end
end