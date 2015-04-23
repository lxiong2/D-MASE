function [f1, Gain1, g1, H1, h1] = myfun_Part1_overlap(buses, numbus, allbuses_a, adjbuses, lines, G_a, B_a, z_a, R_a, type_a, allindices_a, x_a, c, y, rho)
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
% f1
% Gain1         LOCAL Gain matrix
% g1            LOCAL right hand side
% H1            LOCAL measurement Jacobian
% h1            LOCAL ideal measurement vector

%% Slack bus zeroed out
numbus_a = size(allbuses_a,1);
e = x_a(1:size(allbuses_a,1));
f = [0; x_a(size(allbuses_a,1)+1:(2*numbus_a-1),1)]; % assumes slack bus is bus 1

% Nonlinear h's
h1 = createhvector_rect(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);

H1 = createHmatrix_rect(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);
H1 = [H1(:,1:size(allbuses_a,1)) H1(:,(size(allbuses_a,1)+2):size(allbuses_a,1)*2)]; %assumes slack is bus 1 so remove first column

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
