function [dQijde, dQijdf] = reactivePowerFlowMeas_rect(e,f,G,B,numbus,buses_a,lines,indQFmeas)
% Elements of the measurement Jacobian H corresponding to
% reactive power flow measurements

dQijde = zeros(1,numbus);
dQijdf = zeros(1,numbus);
busIndex_a = (1:size(buses_a,1)).';
bsi = 0;
lineNum = 0;

m = busIndex_a(buses_a==indQFmeas(1,1));
n = busIndex_a(buses_a==indQFmeas(1,2));
for c = 1:size(lines,1)
    if sum(indQFmeas(1,1:3) == lines(c,1:3))==3
        lineNum = c;
    end
end
if lines(lineNum,6) ~= 0
    bsi = lines(lineNum,6)/2;
end 

for b = 1:size(lines,1)
    dQijde(1,m) = 2*B(m,n)*e(m)-B(m,n)*e(n)-G(m,n)*f(n)-2*e(m)*bsi;
    dQijde(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
    dQijdf(1,m) = 2*B(m,n)*f(m)-B(m,n)*f(n)+G(m,n)*e(n)-2*f(m)*bsi;
    dQijdf(1,n) = -B(m,n)*f(m)-G(m,n)*e(m);
    
%     dQijde(1,m) = -2*B(m,m)*e(m)+(-G(m,n)*f(n)-B(m,n)*e(n));
%     dQijde(1,n) = -B(m,n)*e(m)+G(m,n)*f(m);
%     dQijdf(1,m) = -2*B(m,m)*f(m)+(G(m,n)*e(n)-B(m,n)*f(n));
%     dQijdf(1,n) = -G(m,n)*e(m)-B(m,n)*f(m);
end