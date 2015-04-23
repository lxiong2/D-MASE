function [dPde, dPdf] = realPowerInjMeas_rect(e,f,G,B,numbus,buses,buses_a,adjbuses,indPmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dPde = zeros(1,size(buses_a,1));
dPdf = zeros(1,size(buses_a,1));
busIndex = (1:numbus).';
busIndex_a = (1:size(buses_a,1)).';

for a = 1:size(buses_a,1)
    m_global = busIndex(buses==indPmeas(1,1));
    m = busIndex_a(buses_a==indPmeas(1,1));
    if m == a
        dPde(1,m) = G(m,m)*e(m)+B(m,m)*f(m);
        dPdf(1,m) = -B(m,m)*e(m)+G(m,m)*f(m);
        temp = adjbuses(m_global,:); % get list of adjacent buses for bus m
        temp = temp(temp~=0); % remove padded zeros
        for b = 1:size(temp,2) % go through each adjacent bus
            n = busIndex_a(buses_a == temp(b));
            dPde(1,m) = dPde(1,m)+(G(m,n)*e(n)-B(m,n)*f(n));
            dPdf(1,m) = dPdf(1,m)+(G(m,n)*f(n)+B(m,n)*e(n));
        end
    else
        dPde(1,a) = G(m,a)*e(m)+B(m,a)*f(m);
        dPdf(1,a) = -B(m,a)*e(m)+G(m,a)*f(m);
    end
end