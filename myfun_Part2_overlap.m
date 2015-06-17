function [f2, Gain2, g2, H2, h2] = myfun_Part2_overlap(buses, numbus, allbuses_a, adjbuses, lines, slackIndex_a, G_a, B_a, z_a, R_a, type_a, allindices_a, x_a, c_a, y_a, rho)
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
e = x_a(1:numbus_a);
f = x_a(numbus_a+1:(2*numbus_a)); % take out slack bus for Areas 2-4

%% Nonlinear h's
h2 = createhvector_rectADMM(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);

H2 = createHmatrix_rectADMM(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);
% size(H2(:,1:numbus_a))
% size(H2(:,(numbus_a+1):(numbus_a+slackIndex_a-1)))
% size(zeros(size(z_a,1),1))
% size(H2(:,(numbus_a+slackIndex_a+1):2*numbus_a))
H2 = [H2(:,1:numbus_a) H2(:,(numbus_a+1):(numbus_a+slackIndex_a-1)) zeros(size(z_a,1),1) H2(:,(numbus_a+slackIndex_a+1):2*numbus_a)];

f2 = (z_a-h2).'*(R_a\(z_a-h2));
Gain2 = 2*H2.'*(R_a\H2)+rho;

% size(-2*H2.')
% size(R_a)
% size(z_a-h2)
% size(y_a)
% size(x_a)
% size(c_a)

g2 = -2*H2.'*(R_a\(z_a-h2)) + y_a + rho*(x_a-c_a); %DEBUG: is y a row or column vector? What about c?
