function [f1, Gain1, g1, H1, h1] = myfun_Part1_AC_3bus(buses, numbus, allbuses_a, adjbuses, lines, G, B, z_a, R_a, type_a, allindices_a, x_a, c, y, rho)

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
e = [x_a(1); x_a(2); x_a(3)];
f = [0; x_a(4); x_a(5)];

%% Nonlinear h's
h1 = createhvector_rect(e,f,G,B,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines)

H1 = createHmatrix_ADMM(theta,V,G,B,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);
%assumes slack is bus 1 so remove first column
H1 = H1(:,2:6);

f1 = (z_a-h1).'*(R_a\(z_a-h1));
Gain1 = 2*H1.'*(R_a\H1)+rho;

% for a = 1:size(allbuses_a,1)-1 %remove slack bus
%     c1(a,1) = c(allbuses_a(a+1));
% end

g1 = -2*H1.'*(R_a\(z_a-h1)) + y + rho*(x_a-c); %DEBUG: is y a row or column vector? What about c?
