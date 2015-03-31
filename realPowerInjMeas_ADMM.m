function [dPdth, dPdV] = realPowerInjMeas_ADMM(theta,V,G,B,numbus,buses,allbuses_a,adjbuses,indPmeas)
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
                (-G(m,a)*sin(theta(m_a)-theta(a_a))+...
                B(m,a)*cos(theta(m_a)-theta(a_a)));
        end
        dPdV(1,m_a) = V(m_a)*G(m,m);
        for d = 1:size(adjbuses(1,:))
            b = adjbuses(m,d);
            b_a = busIndex_a(allbuses_a==adjbuses(m,d));
            dPdV(1,m_a) = dPdV(1,m_a) + V(b_a)*...
                (G(m,b)*cos(theta(m_a)-theta(b_a))+...
                B(m,b)*sin(theta(m_a)-theta(b_a)));
        end
    else
        dPdth(1,n_a) = V(m_a)*V(n_a)*(G(m,n)*...
            sin(theta(m_a)-theta(n_a))-B(m,n)*cos(theta(m_a)-theta(n_a)));
        dPdV(1,n_a) = V(m_a)*(G(m,n)*...
            cos(theta(m_a)-theta(n_a))+B(m,n)*sin(theta(m_a)-theta(n_a)));
    end
end