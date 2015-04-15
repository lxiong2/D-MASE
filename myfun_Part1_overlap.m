function [f1, Gain1, g1, H1, h1] = myfun_Part1_overlap(buses, numbus, allbuses_a, lines, G, B, z_a, R_a, type_a, allindices_a, x_a, c, y, rho)

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
f = [0; x_a(size(allbuses_a,1)+1:(2*numbus_a-1),1)]; % assumes slack bus is bus 1

%% Nonlinear h's
h1 = createhvector_rect(e,f,G,B,type_a,allindices_a,numbus_a,buses,lines);

H1 = createHmatrix_rect(e,f,G,B,type_a,allindices_a,numbus_a,buses,lines);

%DC so remove the voltage columns
H1 = H1(:,2:size(allbuses_a,1)*2); %assumes slack is bus 1 so remove first column

f1 = (z_a-h1).'*(R_a\(z_a-h1));
Gain1 = 2*H1.'*(R_a\H1)+rho;

c1 = zeros(size(allbuses_a,1)*2-1,1);
for a = 1:(size(allbuses_a,1)) 
    c1(a,1) = c(allbuses_a(a));
end
for a = 1:(size(allbuses_a,1)-1) %remove slack bus from f
    c1(size(allbuses_a,1)+a,1) = c(numbus+allbuses_a(a+1));
end

g1 = -2*H1.'*(R_a\(z_a-h1)) + y + rho*(x_a-c1); %DEBUG: is y a row or column vector? What about c?
