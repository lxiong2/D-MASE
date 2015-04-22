function [f2, Gain2, g2, H2, h2] = myfun_Part2_overlap(buses, numbus, allbuses_a, adjbuses, lines, G, B, z_a, R_a, type_a, allindices_a, x_a, c, y, rho)

% buses: 
% numbus:
% adjbuses: table of what buses each bus is connected to
% lines: 
% x_a is the system state
% z_a: measurements for Partition 1
% R_a: % deviation for each measurement
% type_a: measurement type
% indices_a: indices for each measurement

% Slack bus zeroed out
numbus_a = size(allbuses_a,1);
e = x_a(1:size(allbuses_a,1));
f = x_a(size(allbuses_a,1)+1:(2*numbus_a)); % assumes slack bus is bus 1

%% Nonlinear h's
h2 = createhvector_rect(e,f,G,B,type_a,allindices_a,numbus_a,buses,lines);

H2 = createHmatrix_rect(e,f,G,B,type_a,allindices_a,numbus_a,buses,lines);
size(H2)
[Hrow,Hcol] = size(H2);

%DC so remove the voltage columns
H2 = H2(:,1:size(allbuses_a,1)); %assumes slack is bus 1 so remove first column

f2 = (z_a-h2).'*(R_a\(z_a-h2));
Gain2 = 2*H2.'*(R_a\H2)+rho;

c2 = zeros(size(allbuses_a,1)*2-1,1);
c = 1:numbus*2;
for a = 1:(size(allbuses_a,1)) 
    c2(a,1) = c(allbuses_a(a));
    c2(size(allbuses_a,1)+a,1) = c(numbus+allbuses_a(a));
end
c2

size(-2*H2.'*(R_a\(z_a-h2)))
size(y)
size(rho*(x_a-c2))

g2 = -2*H2.'*(R_a\(z_a-h2)) + y + rho*(x_a-c2); %DEBUG: is y a row or column vector? What about c?
