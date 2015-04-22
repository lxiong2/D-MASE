% IEEE 14-Bus Case with 4 partitions
% See Kekatos 2013 paper and Korres 2011 paper for more details on the
% measurements and partition lines

clc
clear all
close all
format long

% System parameters
example_14bus_IEEE_rect

numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

Ybus = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

%% Partition a 14-bus system into 4 pieces
numPart = 2;
iter = 1;
maxiter = 20;
rho = 10; % step size

% Initialize each partition's state vectors
% x1_k = [th1 th2 th4' th5 th6']
x1_k = zeros(size(allbuses1,1)*2-1,maxiter); % Area S1: 3 buses, bus 1 is the slack; if you remove bus1 from x1_k, then the Gain matrix is singular
dx1_k = zeros(size(allbuses1,1)*2-1,maxiter);
% x2_k = [th2' th3 th4 th5' th7 th8 th9']
x2_k = zeros(size(allbuses2,1)*2,maxiter); % Area S2: 4 buses
dx2_k = zeros(size(allbuses2,1)*2,maxiter);
% x3_k = [th6 th11 th12 th13 th14']
x3_k = zeros(size(allbuses3,1)*2,maxiter); % Area S3: 4 buses
dx3_k = zeros(size(allbuses3,1)*2,maxiter);
% x4_k = [th9 th10 th11' th13' th14]
x4_k = zeros(size(allbuses4,1)*2,maxiter); % Area S4: 3 buses
dx4_k = zeros(size(allbuses4,1)*2,maxiter);

% Constraints
% c_k = [th1 th2 th3 th4 th5 th6 th7 th8 th9 th10 th11 th12 th13 th14]
c_k = zeros(numbus*2,maxiter);
y1_kl = zeros(size(allbuses1,1)*2-1,maxiter); %same length as x1_k vector
y2_kl = zeros(size(allbuses2,1)*2,maxiter);
y3_kl = zeros(size(allbuses3,1)*2,maxiter);
y4_kl = zeros(size(allbuses4,1)*2,maxiter);

normres_r = zeros(1,maxiter);
normres_s = zeros(1,maxiter);

f1 = zeros(1,maxiter);
f2 = zeros(1,maxiter);
f3 = zeros(1,maxiter);
f4 = zeros(1,maxiter);

% initialize first guess
% x1_k = [th2 th4' th5 th6'] %th1 - bus 1 is slack
% x2_k = [th2' th3 th4 th5' th7 th8 th9']
% x3_k = [th6 th11 th12 th13 th14']
% x4_k = [th9 th10 th11' th13' th14]
x1_k(:,1) = [ones(size(allbuses1,1),1); zeros(size(allbuses1,1)-1,1)]; %AC flat start
x2_k(:,1) = [ones(size(allbuses2,1),1); zeros(size(allbuses2,1),1)]; %AC flat start
x3_k(:,1) = [ones(size(allbuses3,1),1); zeros(size(allbuses3,1),1)]; %AC flat start
x4_k(:,1) = [ones(size(allbuses4,1),1); zeros(size(allbuses4,1),1)]; %AC flat start

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

while ((sqrt(normres_r(:,iter)) > eps_pri) || (sqrt(normres_s(:,iter)) > eps_dual)) && (iter < maxiter)   
    % Partition 1 calculations
    [tempf1, tempGain1, g1, tempH1, temph1] = myfun_Part1_overlap(buses, numbus, allbuses1, lines, G, B, allz1, allR1, alltype1, allindices1, x1_k(:,iter), c_k(:,iter), y1_kl(:,iter), rho);
    Gain1(:,:,iter) = tempGain1;
    H1(:,:,iter) = tempH1;
    h1(:,iter) = temph1;
    f1(:,iter+1) = tempf1;
    dx1_k(:,iter+1) = -Gain1(:,:,iter)\g1;
    x1_k(:,iter+1) = x1_k(:,iter) + dx1_k(:,iter+1);
    
    % Partition 2 calculations
    [tempf2, tempGain2, g2, tempH2, temph2] = myfun_Part2_overlap(buses, numbus, allbuses2, adjbuses, lines, G, B, allz2, allR2, alltype2, allindices2, x2_k(:,iter), c_k(:,iter), y2_kl(:,iter), rho);
    Gain2(:,:,iter) = tempGain2;
    H2(:,:,iter) = tempH2;
    h2(:,iter) = temph2;
    f2(:,iter+1) = tempf2;
    dx2_k(:,iter+1) = -Gain2(:,:,iter)\g2;
    x2_k(:,iter+1) = x2_k(:,iter) + dx2_k(:,iter+1);
   
    % Partition 3 calculations
    [tempf3, tempGain3, g3, tempH3, temph3] = myfun_Part2_overlap(buses, numbus, allbuses3, adjbuses, lines, G, B, allz3, allR3, alltype3, allindices3, x3_k(:,iter), c_k(:,iter), y3_kl(:,iter), rho);
    Gain3(:,:,iter) = tempGain3;
    H3(:,:,iter) = tempH3;
    h3(:,iter) = temph3;
    f3(:,iter+1) = tempf3;
    dx3_k(:,iter+1) = -Gain3(:,:,iter)\g3;
    x3_k(:,iter+1) = x3_k(:,iter) + dx3_k(:,iter+1);
    
    % Partition 4 calculations
    [tempf4, tempGain4, g4, tempH4, temph4] = myfun_Part2_overlap(buses, numbus, allbuses4, adjbuses, lines, G, B, allz4, allR4, alltype4, allindices4, x4_k(:,iter), c_k(:,iter), y4_kl(:,iter), rho);
    Gain4(:,:,iter) = tempGain4;
    H4(:,:,iter) = tempH4;
    h4(:,iter) = temph4;
    f4(:,iter+1) = tempf4;
    dx4_k(:,iter+1) = -Gain4(:,:,iter)\g4;
    x4_k(:,iter+1) = x4_k(:,iter) + dx4_k(:,iter+1);
    
    % How global variables are collected and averaged
    % DEBUG: need function to automatically map how the state variable for each partition
    % matches up with the global c indexing
    c_k(2,iter+1) = 1/numPart*(x1_k(1,iter+1) + x2_k(1,iter+1)); % the other two variables are 0
    c_k(4,iter+1) = 1/numPart*(x1_k(2,iter+1) + x2_k(3,iter+1));
    c_k(5,iter+1) = 1/numPart*(x1_k(3,iter+1) + x2_k(4,iter+1));
    c_k(6,iter+1) = 1/numPart*(x1_k(4,iter+1) + x3_k(1,iter+1));
    c_k(9,iter+1) = 1/numPart*(x2_k(7,iter+1) + x4_k(1,iter+1));
    c_k(11,iter+1) = 1/numPart*(x3_k(2,iter+1) + x4_k(3,iter+1));
    c_k(13,iter+1) = 1/numPart*(x3_k(4,iter+1) + x4_k(5,iter+1));
    c_k(14,iter+1) = 1/numPart*(x3_k(5,iter+1) + x4_k(5,iter+1));
   
    % Remap from global c_k to the indexing for each partition's state
    % vector
    % DEBUG - also need automatic function to do that
    c1_k(:,iter+1) = [c_k(2,iter+1); c_k(4,iter+1); c_k(5,iter+1); c_k(6,iter+1)];
    c2_k(:,iter+1) = [c_k(2,iter+1); c_k(3,iter+1); c_k(4,iter+1); c_k(5,iter+1); c_k(7,iter+1); c_k(8,iter+1); c_k(9,iter+1)];
    c3_k(:,iter+1) = [c_k(6,iter+1); c_k(11,iter+1); c_k(12,iter+1); c_k(13,iter+1); c_k(14,iter+1)];
    c4_k(:,iter+1) = [c_k(9,iter+1); c_k(10,iter+1); c_k(11,iter+1); c_k(13,iter+1); c_k(14,iter+1)];
        
    y1_kl(:,iter+1) = y1_kl(:,iter) + rho*(x1_k(:,iter+1) - c1_k(:,iter+1));
    y2_kl(:,iter+1) = y2_kl(:,iter) + rho*(x2_k(:,iter+1) - c2_k(:,iter+1));
    y3_kl(:,iter+1) = y3_kl(:,iter) + rho*(x3_k(:,iter+1) - c3_k(:,iter+1));
    y4_kl(:,iter+1) = y4_kl(:,iter) + rho*(x4_k(:,iter+1) - c4_k(:,iter+1));
    
    normres_r(:,iter+1) = (norm(x1_k(:,iter+1) - c1_k(:,iter+1)))^2 +...
                          (norm(x2_k(:,iter+1) - c2_k(:,iter+1)))^2 +...
                          (norm(x3_k(:,iter+1) - c3_k(:,iter+1)))^2 +...
                          (norm(x4_k(:,iter+1) - c4_k(:,iter+1)))^2;
    normres_s(:,iter+1) = numPart*rho^2*(norm(c_k(:,iter+1) - c_k(:,iter)))^2;
    
    iter = iter+1;
end

% for i = 1:maxiter
%     diffx(:,i) = norm(x1_k(:,i) - x2_k(:,i));
% end
% 
x1_k
x2_k
x3_k
x4_k
c_k
% y1_kl
% y2_kl
% y3_kl
% y4_kl
% 
% diffx
% 
figure(1)
semilogy(normres_r)
hold on
semilogy(normres_s)
title('4-Partition, 14-Bus State Estimation Consensus Problem')
legend('Primal residual', 'Dual residual')

figure(2)
for a = 1:maxiter
    temp(a) = norm(x1_k(:,a));
end
plot(1:maxiter,temp)

% 
% figure(2)
% clf
% plot(f1)
% hold on
% plot(f2)
% title('2-Partition, 3-Bus State Estimation Consensus Problem')
% legend('Partition 1 obj function','Partition 2 obj function')