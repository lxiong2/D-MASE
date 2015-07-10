function [f, Gain, g, h, H] = myfun_overlap(buses, numbus, allbuses_a, adjbuses, lines, slackIndex_a, G_a, B_a, z_a, R_a, type_a, allindices_a, x_a, c_a, y_a, rho)
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
% f             LOCAL objective function?
% Gain          LOCAL Gain matrix
% g             LOCAL right hand side
% H             LOCAL measurement Jacobian
% h             LOCAL ideal measurement vector

%% Slack bus zeroed out
numbus_a = size(allbuses_a,1);
e = x_a(1:numbus_a,1);
f = x_a(numbus_a+1:(2*numbus_a));

% Nonlinear h's
h = createhvector_rectADMM(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);

H = createHmatrix_rectADMM(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);
%Pad the slack column with zeros, so that the calculation of g isn't affected
H = [H(:,1:numbus_a) H(:,(numbus_a+1):(numbus_a+slackIndex_a-1)) zeros(size(z_a,1),1) H(:,(numbus_a+slackIndex_a+1):2*numbus_a)]; 

f = (z_a-h).'*(R_a\(z_a-h));
Gain = 2*H.'*(R_a\H)+rho;

g = -2*H.'*(R_a\(z_a-h)) + y_a + rho*(x_a-c_a); %DEBUG: is y a row or column vector? What about c?
