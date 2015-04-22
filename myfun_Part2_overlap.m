function [f2, Gain2, g2, H2, h2] = myfun_Part2_overlap(buses, numbus, allbuses_a, adjbuses, lines, G_a, B_a, z_a, R_a, type_a, allindices_a, x_a, c, y, rho)
%% Inputs:
% This function calculates rectangular state estimation
% Uses rectangular power flow, i.e. V_i = e_i + j*f_i = |V_i| ang (theta_i)

% buses         list of buses in overall system
% numbus        number of buses in overall system
% allbuses_a    list of buses in each PARTITION
% adjbuses      table of what buses each bus is connected to
% lines         list of lines in overall system
% G_a           real part of the LOCAL Ybus matrix
% B_a           imaginary part of the LOCAL Ybus matrix
% z_a           list of LOCAL measurements
% R_a           each PARTITION's standard deviation for each measurement
% type_a        each PARTITION's measurement type
% allindices_a  list of LOCAL indices for each measurement
% x_a           LOCAL system state
% c             
% y
% rho           ADMM step size

%% Outputs: See Decentralized ADMM formulation.docx
% f2
% Gain2         LOCAL Gain matrix
% g2            LOCAL right hand side
% H2            LOCAL measurement Jacobian
% h2            LOCAL ideal measurement vector

%% Slack bus zeroed out
numbus_a = size(allbuses_a,1);
e = x_a(1:size(allbuses_a,1));
f = x_a(size(allbuses_a,1)+1:(2*numbus_a)); % no need to take out slack since assume slack bus is bus 1

%% Nonlinear h's
h2 = createhvector_rect(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);
%(e,f,G,B,type_a,allindices_a,numbus_a,buses,lines);

H2 = createHmatrix_rect(e,f,G_a,B_a,type_a,allindices_a,numbus_a,buses,lines);
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
