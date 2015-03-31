function [dPijdth, dPijdV] = realPowerFlowMeas_ADMM(theta,V,numbus,buses,allbuses_a,lines,indPFmeas)
% Elements of the measurement Jacobian H corresponding to
% real power flow measurements

numbus_a = size(allbuses_a,1);
dPijdth = zeros(1, numbus_a);
dPijdV = zeros(1, numbus_a);
busIndex = (1:numbus).';
busIndex_a = (1:numbus_a).';

m = busIndex_a(allbuses_a==indPFmeas(1,1));
n = busIndex_a(allbuses_a==indPFmeas(1,2));
for b = 1:size(lines,1)
    if sum(lines(b,1:3) == indPFmeas(1,:))==3 || ...
            ((lines(b,1)==indPFmeas(1,2))&&(lines(b,2)==indPFmeas(1,1)) && ...
            (lines(b,3)==indPFmeas(1,3)))
        ytemp = 1/(lines(b,4)+1i*lines(b,5));
        gij = real(ytemp);
        bij = imag(ytemp);
        gsi = 0;
        dPijdth(1,m) = V(m)*V(n)*(gij*sin(theta(m)-theta(n))-...
            bij*cos(theta(m)-theta(n)));
        dPijdth(1,n) = -V(m)*V(n)*(gij*sin(theta(m)-theta(n))-...
            bij*cos(theta(m)-theta(n)));
        dPijdV(1,m) = -V(n)*(gij*cos(theta(m)-theta(n))+...
            bij*sin(theta(m)-theta(n)))+2*(gij+gsi)*V(m);
        dPijdV(1,n) = -V(m)*(gij*cos(theta(m)-theta(n))+...
            bij*sin(theta(m)-theta(n)));
    end
end