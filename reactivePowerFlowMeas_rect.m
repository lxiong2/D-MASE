function [dQijde, dQijdf] = reactivePowerFlowMeas_rect(e,f,G,B,buses,lines,indQFmeas)
% Elements of the measurement Jacobian H corresponding to
% reactive power flow measurements

dQijde = zeros(1,size(buses,1));
dQijdf = zeros(1,size(buses,1));
bsi = 0;

m = find(buses==indQFmeas(1,1));
n = find(buses==indQFmeas(1,2));
ckt = indQFmeas(1,3);

paraLines1 = intersect(find(lines(:,1)==indQFmeas(1,1)),find(lines(:,2)==indQFmeas(1,2)));
paraLines2 = intersect(find(lines(:,2)==indQFmeas(1,1)),find(lines(:,1)==indQFmeas(1,2)));
paraLines = [paraLines1; paraLines2];
lineNum = intersect(paraLines,find(lines(:,3)==ckt));

if lines(lineNum,6) ~= 0
    bsi = lines(lineNum,6)/2;
end

if size(paraLines,1) == 1
    dQijde(1,m) = 2*B(m,n)*e(m)-B(m,n)*e(n)-G(m,n)*f(n)-2*e(m)*bsi;
    dQijde(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
    dQijdf(1,m) = 2*B(m,n)*f(m)-B(m,n)*f(n)+G(m,n)*e(n)-2*f(m)*bsi;
    dQijdf(1,n) = -B(m,n)*f(m)-G(m,n)*e(m);
else
    Zeq = lines(lineNum,4)+1i*lines(lineNum,5);         
    g = real(1/Zeq);
    b = imag(1/Zeq);
    gmn = -g;
    bmn = -b;
    bmm = b+bsi;
    dQijde(1,m) = -2*bmm*e(m)-bmn*e(n)-gmn*f(n);
    dQijde(1,n) = -bmn*e(m)+gmn*f(m);
    dQijdf(1,m) = -2*bmm*f(m)-bmn*f(n)+gmn*e(n);
    dQijdf(1,n) = -bmn*f(m)-gmn*e(m);
end
    
% dQijde(1,m) = -2*B(m,m)*e(m)+(-G(m,n)*f(n)-B(m,n)*e(n));
% dQijde(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
% dQijdf(1,m) = -2*B(m,m)*f(m)+(G(m,n)*e(n)-B(m,n)*f(n));
% dQijdf(1,n) = -G(m,n)*e(m)-B(m,n)*f(m);
