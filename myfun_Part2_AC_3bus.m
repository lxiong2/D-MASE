function [f2, Gain2, g2, H2, h2] = myfun_Part2_AC_3bus(buses, numbus, allbuses_a, adjbuses, lines, G, B, z_a, R_a, type_a, allindices_a, x_a, c, y, rho)

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
theta = [0; x_a(1); x_a(2)];
V = [x_a(3); x_a(4); x_a(5)];

%% Nonlinear h's
h2 = createhvector_ADMM(theta,V,G,B,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);

H2 = createHmatrix_ADMM(theta,V,G,B,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);
%assumes slack is bus 1 so remove first column
H2 = H2(:,2:6);

f2 = (z_a-h2).'*(R_a\(z_a-h2));
Gain2 = 2*H2.'*(R_a\H2)+rho;

% for a = 1:size(allbuses_a,1)-1 %remove slack bus
%     c2(a,1) = c(allbuses_a(a+1));
% end

g2 = -2*H2.'*(R_a\(z_a-h2)) + y + rho*(x_a-c); %DEBUG: is y a row or column vector? What about c?
