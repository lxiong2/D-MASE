function [dQde, dQdf] = reactivePowerInjMeas_rect(e,f,G,B,numbus,buses,buses_a,adjbuses,indQmeas)
% Elements of the measurement Jacobian H corresponding to
% real power injection measurements

dQde = zeros(1,size(buses_a,1));
dQdf = zeros(1,size(buses_a,1));
busIndex = (1:numbus).';
busIndex_a = (1:size(buses_a,1)).';

for a = 1:size(buses_a,1)
    m_global = busIndex(buses==indQmeas(1,1));
    m = busIndex_a(buses_a==indQmeas(1,1));
    if m == a
        dQde(1,m) = -B(m,m)*e(m)+G(m,m)*f(m);
        dQdf(1,m) = -G(m,m)*e(m)-B(m,m)*f(m);
        temp = adjbuses(m_global,:); % get list of adjacent buses for bus m
        temp = temp(temp~=0); % remove padded zeros
        for b = 1:size(temp,2) % go through each adjacent bus
            n = busIndex_a(buses_a == temp(b));
            dQde(1,m) = dQde(1,m) + (-G(m,n)*f(n)-B(m,n)*e(n));
            dQdf(1,m) = dQdf(1,m) + (G(m,n)*e(n)-B(m,n)*f(n));
        end
    else
        dQde(1,a) = -B(m,a)*e(m)+G(m,a)*f(m);
        dQdf(1,a) = -G(m,a)*e(m)-B(m,a)*f(m);
    end
end