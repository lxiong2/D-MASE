function [dQijdth dQijdV] = reactivePowerFlowMeas(theta,V,numbus,buses,lines,indQFmeas)
% Elements of the measurement Jacobian H corresponding to
% reactive power flow measurements

dQijdth = zeros(1, numbus);
dQijdV = zeros(1, numbus);
busIndex = (1:numbus).';

m = busIndex(buses==indQFmeas(1,1));
n = busIndex(buses==indQFmeas(1,2));
for b = 1:size(lines,1)
    if sum(lines(b,1:3) == indQFmeas(1,:))==3 || ...
            ((lines(b,1)==indQFmeas(1,2))&&(lines(b,2)==indQFmeas(1,1)) && ...
            (lines(b,3)==indQFmeas(1,3)))
        ytemp = 1/(lines(b,4)+1i*lines(b,5));
        gij = real(ytemp);
        bij = imag(ytemp);
        if lines(b,6) ~= 0
            bsi = 1/lines(b,6);
        else bsi = 0;
        end
        dQijdth(1,m) = -V(m)*V(n)*(gij*cos(theta(m)-theta(n))+...
            bij*sin(theta(m)-theta(n)));
        dQijdth(1,n) = V(m)*V(n)*(gij*cos(theta(m)-theta(n))+...
            bij*sin(theta(m)-theta(n)));
        dQijdV(1,m) = -V(n)*(gij*sin(theta(m)-theta(n))-...
            bij*cos(theta(m)-theta(n)))-2*(bij+bsi)*V(m);
        dQijdV(1,n) = -V(m)*(gij*sin(theta(m)-theta(n))-...
            bij*cos(theta(m)-theta(n)));
    end
end