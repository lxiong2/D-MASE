% IEEE 14-Bus Case with 4 partitions
% See Kekatos 2013 paper and Korres 2011 paper for more details on the
% measurements and partition lines

clc
clear all
close all
format long

% System parameters
%example_14bus_IEEE_rectADMM
example_14bus_IEEE_partitions

numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

YBus_14AC
%Ybus = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

% Partial G, B matrices for each partition
G1 = G(allbuses1,allbuses1); % get submatrix for Partition 1
B1 = B(allbuses1,allbuses1);

G2 = G(allbuses2,allbuses2); % get submatrix for Partition 2
B2 = B(allbuses2,allbuses2);

G3 = G(allbuses3,allbuses3); % get submatrix for Partition 3
B3 = B(allbuses3,allbuses3);

G4 = G(allbuses4,allbuses4); % get submatrix for Partition 4
B4 = B(allbuses4,allbuses4);

%% Partition a 14-bus system into 4 pieces
%numPart = zeros(numbus*2,1);
numPart = 2;
iter = 1;
maxiter = 10;
rho = 10; % step size

% Initialize each partition's state vectors
% x1_k = [bus1 bus2 bus3' bus4' bus5 bus6']
x1_k = zeros(size(allbuses1,1)*2-1,maxiter); % Area S1: 3 buses, bus 1 is the slack for Partition 1; if you remove bus1 from x1_k, then the Gain matrix is singular
dx1_k = zeros(size(allbuses1,1)*2-1,maxiter);
% x2_k = [bus2' bus3 bus4 bus5' bus7 bus8 bus9']
x2_k = zeros(size(allbuses2,1)*2-1,maxiter); % Area S2: 4 buses, bus 3 is the slack for Partition 2
dx2_k = zeros(size(allbuses2,1)*2-1,maxiter);
% x3_k = [bus5' bus6 bus10' bus11 bus12 bus13 bus14']
x3_k = zeros(size(allbuses3,1)*2-1,maxiter); % Area S3: 4 buses, bus 6 is the slack for Partition 3
dx3_k = zeros(size(allbuses3,1)*2-1,maxiter);
% x4_k = [bus4' bus7' bus9 bus10 bus11' bus13' bus14]
x4_k = zeros(size(allbuses4,1)*2-1,maxiter); % Area S4: 3 buses, bus 9 is the slack for Partition 4
dx4_k = zeros(size(allbuses4,1)*2-1,maxiter);

% Constraints
% c_k = [e1 ... e14 f1 ... f14]
c_k = zeros(numbus*2,maxiter);
c1_k = zeros(size(x1_k,1),1);
c2_k = zeros(size(x2_k,1),1);
c3_k = zeros(size(x3_k,1),1);
c4_k = zeros(size(x4_k,1),1);

y1_kl = zeros(size(allbuses1,1)*2-1,maxiter); %same length as x1_k vector
y2_kl = zeros(size(allbuses2,1)*2-1,maxiter);
y3_kl = zeros(size(allbuses3,1)*2-1,maxiter);
y4_kl = zeros(size(allbuses4,1)*2-1,maxiter);

normres_r = zeros(1,maxiter);
normres_s = zeros(1,maxiter);

f1 = zeros(1,maxiter);
f2 = zeros(1,maxiter);
f3 = zeros(1,maxiter);
f4 = zeros(1,maxiter);

% initialize first guess
% x1_k = [e1 e2 e3' e4' e5 e6' f2 f3' f4' f5 f6'] %f1 - bus 1 is slack
% x2_k = [e2' e3 e4 e5' e7 e8 e9' f2' f4 f5' f7 f8 f9'] % f3 - bus 3 is the
% slack
% x3_k = [e5' e6 e11 e12 e13 e14' f5' f11 f12 f13 f14'] % f6 - bus 6 is
% the slack
% x4_k = [e4' e7' e9 e10 e11' e13' e14 f4' f7' f10 f11' f13' f14] % f9 - bus 9 is the
% slack
x1_k(:,1) = [ones(size(allbuses1,1),1); zeros(size(allbuses1,1)-1,1)]; %AC flat start
x2_k(:,1) = [ones(size(allbuses2,1),1); zeros(size(allbuses2,1)-1,1)]; %AC flat start
x3_k(:,1) = [ones(size(allbuses3,1),1); zeros(size(allbuses3,1)-1,1)]; %AC flat start
x4_k(:,1) = [ones(size(allbuses4,1),1); zeros(size(allbuses4,1)-1,1)]; %AC flat start

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
    [tempf1, tempGain1, g1, tempH1, temph1] = myfun_Part1_overlap(buses, numbus, allbuses1, adjbuses, lines1, slackIndex1, G1, B1, allz1, allR1, alltype1, allindices1, x1_k(:,iter), c_k(:,iter), y1_kl(:,iter), rho);
    Gain1(:,:,iter) = tempGain1;
    H1(:,:,iter) = tempH1;
    h1(:,iter) = temph1;
    f1(:,iter+1) = tempf1;
    dx1_k(:,iter+1) = -Gain1(:,:,iter)\g1;
    x1_k(:,iter+1) = x1_k(:,iter) + dx1_k(:,iter+1);
    
    % Partition 2 calculations
    [tempf2, tempGain2, g2, tempH2, temph2] = myfun_Part2_overlap(buses, numbus, allbuses2, adjbuses, lines2, slackIndex2, G2, B2, allz2, allR2, alltype2, allindices2, x2_k(:,iter), c_k(:,iter), y2_kl(:,iter), rho);
    Gain2(:,:,iter) = tempGain2;
    H2(:,:,iter) = tempH2;
    h2(:,iter) = temph2;
    f2(:,iter+1) = tempf2;
    dx2_k(:,iter+1) = -Gain2(:,:,iter)\g2;
    x2_k(:,iter+1) = x2_k(:,iter) + dx2_k(:,iter+1);
   
    % Partition 3 calculations
    [tempf3, tempGain3, g3, tempH3, temph3] = myfun_Part2_overlap(buses, numbus, allbuses3, adjbuses, lines3, slackIndex3, G3, B3, allz3, allR3, alltype3, allindices3, x3_k(:,iter), c_k(:,iter), y3_kl(:,iter), rho);
    Gain3(:,:,iter) = tempGain3;
    H3(:,:,iter) = tempH3;
    h3(:,iter) = temph3;
    f3(:,iter+1) = tempf3;
    dx3_k(:,iter+1) = -Gain3(:,:,iter)\g3;
    x3_k(:,iter+1) = x3_k(:,iter) + dx3_k(:,iter+1);
    
    % Partition 4 calculations
    [tempf4, tempGain4, g4, tempH4, temph4] = myfun_Part2_overlap(buses, numbus, allbuses4, adjbuses, lines4, slackIndex4, G4, B4, allz4, allR4, alltype4, allindices4, x4_k(:,iter), c_k(:,iter), y4_kl(:,iter), rho);
    Gain4(:,:,iter) = tempGain4;
    H4(:,:,iter) = tempH4;
    h4(:,iter) = temph4;
    f4(:,iter+1) = tempf4;
    dx4_k(:,iter+1) = -Gain4(:,:,iter)\g4;
    x4_k(:,iter+1) = x4_k(:,iter) + dx4_k(:,iter+1);
    
    % How global variables are collected and averaged
    % DEBUG: need function to automatically map how the state variable for each partition
    % matches up with the global c indexing
    % Map Partition 1's state variables to global index
%     for a = 1:size(allbuses1,1)
%         numPart(allbuses1(a)) = numPart(allbuses1(a))+1;
%         c_k(allbuses1(a),iter+1) = c_k(allbuses1(a),iter+1)+x1_k(a,iter+1);
%     end
%     % Assumes slack bus is bus 1 and in Partition 1
%     for a = 2:size(allbuses1,1)
%         numPart(numbus+allbuses1(a)) = numPart(numbus+allbuses1(a))+1;
%         c_k(numbus+allbuses1(a),iter+1) = c_k(numbus+allbuses1(a),iter+1)+x1_k(size(allbuses1,1)+a-1,iter+1); 
%     end
%     % Map Partition 2's state variables to global index
%     for a = 1:size(allbuses2,1)
%         numPart(allbuses2(a)) = numPart(allbuses2(a))+1;
%         numPart(numbus+allbuses2(a)) = numPart(numbus+allbuses2(a))+1;
%         c_k(allbuses2(a),iter+1) = c_k(allbuses2(a),iter+1)+x2_k(a,iter+1);
%         c_k(numbus+allbuses2(a),iter+1) = c_k(numbus+allbuses2(a),iter+1)+x2_k(size(allbuses2,1)+a,iter+1);
%     end
%     % Map Partition 3's state variables to global index
%     for a = 1:size(allbuses3,1)
%         numPart(allbuses3(a)) = numPart(allbuses3(a))+1;
%         numPart(numbus+allbuses3(a)) = numPart(numbus+allbuses3(a))+1;
%         c_k(allbuses3(a),iter+1) = c_k(allbuses3(a),iter+1)+x3_k(a,iter+1);
%         c_k(numbus+allbuses3(a),iter+1) = c_k(numbus+allbuses3(a),iter+1)+x3_k(size(allbuses3,1)+a,iter+1);
%     end
%     % Map Partition 4's state variables to global index
%     for a = 1:size(allbuses4,1)
%         numPart(allbuses4(a)) = numPart(allbuses4(a))+1;
%         numPart(numbus+allbuses4(a)) = numPart(numbus+allbuses4(a))+1;
%         c_k(allbuses4(a),iter+1) = c_k(allbuses4(a),iter+1)+x4_k(a,iter+1);
%         c_k(numbus+allbuses4(a),iter+1) = c_k(numbus+allbuses4(a),iter+1)+x4_k(size(allbuses4,1)+a,iter+1);    
%     end
%     % Actually average across partitions
%     for a = 1:numbus*2
%         if numPart(a) ~= 0
%             c_k(a,iter+1) = c_k(a,iter+1)/numPart(a);
%         end
%     end
%     c_k
    
    c_k(2,iter+1) = 1/numPart*(x1_k(2,iter+1) + x2_k(1,iter+1)); % the other two variables are 0
    c_k(4,iter+1) = 1/numPart*(x1_k(3,iter+1) + x2_k(3,iter+1));
    c_k(5,iter+1) = 1/numPart*(x1_k(4,iter+1) + x2_k(4,iter+1));
    c_k(6,iter+1) = 1/numPart*(x1_k(5,iter+1) + x3_k(1,iter+1));
    c_k(9,iter+1) = 1/numPart*(x2_k(7,iter+1) + x4_k(1,iter+1));
    c_k(11,iter+1) = 1/numPart*(x3_k(2,iter+1) + x4_k(3,iter+1));
    c_k(13,iter+1) = 1/numPart*(x3_k(4,iter+1) + x4_k(4,iter+1));
    c_k(14,iter+1) = 1/numPart*(x3_k(5,iter+1) + x4_k(5,iter+1));
    c_k(numbus+2,iter+1) = 1/numPart*(x1_k(6,iter+1) + x2_k(8,iter+1)); % the other two variables are 0
    c_k(numbus+4,iter+1) = 1/numPart*(x1_k(7,iter+1) + x2_k(10,iter+1));
    c_k(numbus+5,iter+1) = 1/numPart*(x1_k(8,iter+1) + x2_k(11,iter+1));
    c_k(numbus+6,iter+1) = 1/numPart*(x1_k(9,iter+1) + x3_k(6,iter+1));
    c_k(numbus+9,iter+1) = 1/numPart*(x2_k(14,iter+1) + x4_k(6,iter+1));
    c_k(numbus+11,iter+1) = 1/numPart*(x3_k(7,iter+1) + x4_k(8,iter+1));
    c_k(numbus+13,iter+1) = 1/numPart*(x3_k(9,iter+1) + x4_k(9,iter+1));
    c_k(numbus+14,iter+1) = 1/numPart*(x3_k(10,iter+1) + x4_k(10,iter+1));
   
    % Remap from global c_k to the indexing for each partition's state
    % vector
    % DEBUG - also need automatic function to do that
    c1_k(:,iter+1) = [c_k(allbuses1,iter+1); c_k(numbus+allbuses1(2:size(allbuses1,1)),iter+1)];
    c2_k(:,iter+1) = [c_k(allbuses2,iter+1); c_k(numbus+allbuses2,iter+1)];
    c3_k(:,iter+1) = [c_k(allbuses3,iter+1); c_k(numbus+allbuses3,iter+1)];
    c4_k(:,iter+1) = [c_k(allbuses4,iter+1); c_k(numbus+allbuses4,iter+1)];
        
    y1_kl(:,iter+1) = y1_kl(:,iter) + rho*(x1_k(:,iter+1) - c1_k(:,iter+1));
    y2_kl(:,iter+1) = y2_kl(:,iter) + rho*(x2_k(:,iter+1) - c2_k(:,iter+1));
    y3_kl(:,iter+1) = y3_kl(:,iter) + rho*(x3_k(:,iter+1) - c3_k(:,iter+1));
    y4_kl(:,iter+1) = y4_kl(:,iter) + rho*(x4_k(:,iter+1) - c4_k(:,iter+1));
    
    normres_r(:,iter+1) = (norm(x1_k(:,iter+1) - c1_k(:,iter+1)))^2 +...
                          (norm(x2_k(:,iter+1) - c2_k(:,iter+1)))^2 +...
                          (norm(x3_k(:,iter+1) - c3_k(:,iter+1)))^2 +...
                          (norm(x4_k(:,iter+1) - c4_k(:,iter+1)))^2;
    normres_s(:,iter+1) = numPart(:,1).*rho^2*(norm(c_k(:,iter+1) - c_k(:,iter)))^2;
    
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
for a = 1:maxiter-1
    temp1(a) = det(Gain1(:,:,a));
    temp2(a) = det(Gain2(:,:,a)); 
    temp3(a) = det(Gain3(:,:,a));
    temp4(a) = det(Gain4(:,:,a));
end
plot(1:maxiter-1,temp1)
hold on
plot(1:maxiter-1,temp2,'r')
plot(1:maxiter-1,temp3,'bl')
plot(1:maxiter-1,temp4,'g')

% 
% figure(2)
% clf
% plot(f1)
% hold on
% plot(f2)
% title('2-Partition, 3-Bus State Estimation Consensus Problem')
% legend('Partition 1 obj function','Partition 2 obj function')