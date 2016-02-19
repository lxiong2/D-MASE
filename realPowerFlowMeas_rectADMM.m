function [dPijde, dPijdf] = realPowerFlowMeas_rectADMM(e,f,G,B,buses_a,lines,indPFmeas)
% Elements of the measurement Jacobian H corresponding to
% real power flow measurements

dPijde = zeros(1,size(buses_a,1));
dPijdf = zeros(1,size(buses_a,1));
busIndex_a = (1:size(buses_a,1)).';

m = busIndex_a(buses_a==indPFmeas(1,1));
n = busIndex_a(buses_a==indPFmeas(1,2));
ckt = indPFmeas(1,3);

paraLines1 = intersect(find(lines(:,1)==indPFmeas(1,1)),find(lines(:,2)==indPFmeas(1,2)));
paraLines2 = intersect(find(lines(:,2)==indPFmeas(1,1)),find(lines(:,1)==indPFmeas(1,2)));
paraLines = [paraLines1; paraLines2];

if size(paraLines,1) == 1
    dPijde(1,m) = -2*G(m,n)*e(m)+G(m,n)*e(n)-B(m,n)*f(n);
    dPijde(1,n) = G(m,n)*e(m)+B(m,n)*f(m);
    dPijdf(1,m) = -2*G(m,n)*f(m)+G(m,n)*f(n)+B(m,n)*e(n);
    dPijdf(1,n) = G(m,n)*f(m)-B(m,n)*e(m);
else
    lineNum = intersect(paraLines,find(lines(:,3)==ckt));
    Zeq = lines(lineNum,4)+1i*lines(lineNum,5);         
    g = real(1/Zeq);
    b = imag(1/Zeq);
    gmn = -g;
    bmn = -b;
    gmm = g;
    dPijde(1,m) = 2*gmm*e(m)+gmn*e(n)-bmn*f(n);
    dPijde(1,n) = gmn*e(m)+bmn*f(m);
    dPijdf(1,m) = 2*gmm*f(m)+gmn*f(n)+bmn*e(n);
    dPijdf(1,n) = gmn*f(m)-bmn*e(m);
end

% dPijde(1,m) = 2*G(m,m)*e(m)+(G(m,n)*e(n)-B(m,n)*f(n));
% dPijde(1,n) = G(m,n)*e(m)+B(m,n)*f(m);
% dPijdf(1,m) = 2*G(m,m)*f(m)+(G(m,n)*f(n)+B(m,n)*e(n));
% dPijdf(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
