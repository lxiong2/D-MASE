clc
clear all
close all
format long

% 3-bus 2 partition system

% System parameters
buses = [1; 2; 3];
numbus = size(buses,1);
lines = [1 2 1 0.01 0.03 0;
         1 3 1 0.02 0.05 0;
         2 3 1 0.03 0.08 0];
lineNum = size(lines,1);

Ybus = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), {'Closed';'Closed';'Closed'})
G = real(Ybus);
B = imag(Ybus);

%% Partition a simple 3-bus system into 2 pieces
% Partition1 = [bus1; bus3];
% Partition2 = [bus2];

numPart = 2;
iter = 1;
maxiter = 20;
rho = 0.5; % step size

x1_k = zeros(5,maxiter);
dx1_k = zeros(5,maxiter);
x2_k = zeros(5,maxiter);
dx2_k = zeros(5,maxiter);

c_k = zeros(5,maxiter);
y1_kl = zeros(5,maxiter);
y2_kl = zeros(5,maxiter);

normres_r = zeros(1,maxiter);
normres_s = zeros(1,maxiter);

f1 = zeros(1,maxiter);
f2 = zeros(1,maxiter);

% initialize first guess
% x1 = [th2; th3; V1; V2; V3];
% x2 = [th2; th3; V1; V2; V3];
x1_k(:,1) = [0; 0; 1; 1; 1]; %flat start
x2_k(:,1) = [0; 0; 1; 1; 1]; %flat start
normres_r(:,1) = 1; %primal residual - initialize to nonzero number
normres_s(:,1) = 1; %dual residual - initialize to nonzero number

%% Establish stopping conditions
eps_abs = 1;
while eps_abs + 1 > 1
    eps_abs = eps_abs/2;
end
eps_abs = 2*eps_abs; % machine epsilon
eps_rel = 1e-3;

% eps_pri = sqrt(p)*eps_abs + eps_rel*max([normAxk normBzk normc]);
% eps_dual = sqrt(n)*eps_abs + eps_rel*norm(A.'*yk);

eps_pri = 1e-4;
eps_dual = 1e-4;

while ((normres_r(:,iter) > eps_pri) || (normres_s(:,iter) > eps_dual)) && (iter < maxiter)   
    % Partition 1 calculations
    [tempf1, tempGain1, g1, tempH1, temph1] = myfun_Part1_notADMM(buses, numbus, lines, lineNum, G, B, x1_k(:,iter));
    Gain1(:,:,iter) = tempGain1;
    H1(:,:,iter) = tempH1;
    h1(:,iter) = temph1;
    f1(:,iter+1) = tempf1;
    dx1_k(:,iter+1) = -Gain1(:,:,iter)\g1;
    x1_k(:,iter+1) = x1_k(:,iter) + dx1_k(:,iter+1);
    
    % Partition 2 calculations
    [tempf2, tempGain2, g2, tempH2, temph2] = myfun_Part2_notADMM(buses, numbus, lines, lineNum, G, B, x2_k(:,iter));
    Gain2(:,:,iter) = tempGain2;
    H2(:,:,iter) = tempH2;
    h2(:,iter) = temph2;
    f2(:,iter+1) = tempf2;
    dx2_k(:,iter+1) = -Gain2(:,:,iter)\g2;
    x2_k(:,iter+1) = x2_k(:,iter) + dx2_k(:,iter+1);
    
    c_k(:,iter+1) = 1/numPart*(x1_k(:,iter+1) + x2_k(:,iter+1));
    
    x1_k(:,iter+1) = c_k(:,iter+1);
    x2_k(:,iter+1) = c_k(:,iter+1);
        
    normres_r(:,iter+1) = (norm(x1_k(:,iter+1) - c_k(:,iter+1)))^2 + (norm(x2_k(:,iter+1) - c_k(:,iter+1)))^2;
    normres_s(:,iter+1) = numPart*rho^2*(norm(c_k(:,iter+1) - c_k(:,iter)))^2;
    
    iter = iter+1;
end

for i = 1:maxiter
    diffx(:,i) = norm(x1_k(:,i) - x2_k(:,i));
end

for i = 1:iter-1
    condGain1(:,i) = cond(Gain1(:,:,i));
    condGain2(:,i) = cond(Gain2(:,:,i));
end

x1_k
x2_k
c_k
y1_kl
y2_kl

diffx
condGain1
condGain2