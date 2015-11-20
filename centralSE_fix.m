% Traditional central state estimation

clc
clear all
close all
format long

centralt = 0;

k = 1;
maxiter = 20;

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb';
% YBus14
% % load noise14.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 57 bus.pwb';
% YBus57
% %load noise57.mat

option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
%casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_2parts.pwb';
casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_test (2).pwb';
%YBus118
YBus118_test
% load noise118_test.mat
% load noise118.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE300Bus.pwb';
% YBus300
% %load noise300.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\TVASummer15Base_renumbered.pwb';
% YBusTVA
% load noise300.mat

centralSE_setup

%% Add Gaussian noise to measurements
% for a = 1:size(z,1)
%     if (indices(a,1) ~= globalSlack) && (indices(a,2) ~= globalSlack)
%         z(a) = z(a)*(1+noise(a,4));
%     end
% end

%% flat start for AC
x(:,1) = [ones(numbus,1); zeros(numbus-1,1)];

% flat start for DC
%x(:,1) = ones(numbus,1);
deltax(:,1) = ones(size(x,1),1);

lineStatus = repmat({'Closed'},[numlines 1]);

G = real(Ybus);
B = imag(Ybus);

%tic
while (norm(deltax(:,k)) > 1e-4) && (k < maxiter)
    % Polar AC version
%     theta = [0; x(1:numbus-1,k)]; % assumes slack bus is bus 1
%     V = x(numbus:(2*numbus-1),k);
    
    %tic
    % Rectangular AC version
    e = x(1:numbus,k);
    f = [0; x(numbus+1:(2*numbus-1),k)];

    %h(:,k) = zeros(size(z,1),1);
    % Form the measurement function h(x^k)
    %h(:,k) = createhvector_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
    h(:,k) = createhvector_rect(e,f,G,B,type,indices,buses,lines,adjbuses); % rectangular
    
    r(:,k) = z-h(:,k);
    J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    %temp = createHmatrix_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
    tic
    temp = createHmatrix_rect(e,f,G,B,type,indices,numbus,buses,lines,adjbuses);
    
    % only slackIndex+1:(numbus) instead of slackIndex+1:(2*numbus) when
    % we're looking only at DC
    %H(:,:,k) = [temp(:,1:slackIndex-1) temp(:,slackIndex+1:numbus)];
    H(:,:,k) = [temp(:,1:numbus) temp(:,numbus+2:2*numbus)];
    tempt(k) = toc;
    
    % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
    Gain(:,:,k) = H(:,:,k).'*(R\H(:,:,k));
    
    % Compute right-hand side
    rhs(:,k) = H(:,:,k).'*(R\(z-h(:,k)));
    
    % Solve for dx
    deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
    
    % update x and increase iteration count
    x(:,k+1) = x(:,k)+deltax(:,k+1);
    
    %centralt(k) = toc;
    k = k+1;
    
end
%totalt = sum(centralt)
%toc

% Convert rectangular state variables to polar form
newe = x(1:numbus,k);
newf = [0; x(numbus+1:(2*numbus-1),k)];
polarStates = zeros(numbus*2,1);
for a = 1:numbus
    polarStates(a) = atan(newf(a)/newe(a));
    polarStates(numbus+a) = sqrt(newe(a)^2+newf(a)^2);
end

% Compare polarStates against PW's centralized power flow solution
errReport = [];
errThreshold = 1e-4;
diffTrueSoln = zeros(numbus*2,1);
diffTrueSoln = centralPWStates - polarStates;
for a = 1:numbus*2
    if diffTrueSoln(a) > errThreshold
        errReport = [errReport; a centralPWStates(a) polarStates(a)];
    end
end
errReport