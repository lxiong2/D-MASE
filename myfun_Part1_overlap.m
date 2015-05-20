function [f1, Gain1, g1, H1, h1] = myfun_Part1_overlap(buses, numbus, allbuses_a, adjbuses, lines, slackIndex_a, G_a, B_a, z_a, R_a, type_a, allindices_a, x_a, c_a, y_a, rho)
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
% f1            LOCAL objective function?
% Gain1         LOCAL Gain matrix
% g1            LOCAL right hand side
% H1            LOCAL measurement Jacobian
% h1            LOCAL ideal measurement vector

%% Slack bus zeroed out
numbus_a = size(allbuses_a,1);
e = x_a(1:numbus_a,1);
f = x_a(numbus_a+1:2*numbus_a);

% Nonlinear h's
h1 = createhvector_rectADMM(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);

H1 = createHmatrix_rectADMM(e,f,G_a,B_a,type_a,allindices_a,numbus,buses,allbuses_a,adjbuses,lines);
%Pad the slack column with zeros, so that the calculation of g isn't affected
H1 = [H1(:,1:numbus_a) H1(:,(numbus_a+1):(numbus_a+slackIndex_a-1)) zeros(size(z_a,1),1) H1(:,(numbus_a+slackIndex_a+1):2*numbus_a)]; 

f1 = (z_a-h1).'*(R_a\(z_a-h1));
Gain1 = 2*H1.'*(R_a\H1)+rho;

g1 = -2*H1.'*(R_a\(z_a-h1)) + y_a + rho*(x_a-c_a); %DEBUG: is y a row or column vector? What about c?
