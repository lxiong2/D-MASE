function [dPijdth] = realPowerFlowMeas_DC2(theta,V,numbus,buses,lines,indPFmeas)
% Elements of the measurement Jacobian H corresponding to
% real power flow measurements

dPijdth = zeros(1, numbus);
busIndex = (1:numbus).';

m = busIndex(buses==indPFmeas(1,1));
n = busIndex(buses==indPFmeas(1,2));
for b = 1:size(lines,1)
    if sum(lines(b,1:3) == indPFmeas(1,:))==3 || ...
            ((lines(b,1)==indPFmeas(1,2))&&(lines(b,2)==indPFmeas(1,1)) && ...
            (lines(b,3)==indPFmeas(1,3)))
        ytemp = 1/(1i*lines(b,5));
        gij = real(ytemp);
        bij = imag(ytemp);
        gsi = 0;
        dPijdth(1,m) = V(m)*V(n)*(gij*(theta(m)-theta(n))-...
            bij*(1-(theta(m)-theta(n))^2/2));
        dPijdth(1,n) = -V(m)*V(n)*(gij*sin(theta(m)-theta(n))-...
            bij*(1-(theta(m)-theta(n))^2/2));
    end
end