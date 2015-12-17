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
% load noise14.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 57 bus.pwb';
% YBus57
%load noise57.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% %casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_2parts.pwb';
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_test (2).pwb';
% %YBus118
% YBus118_test
% % load noise118_test.mat
% % load noise118.mat

% option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE300Bus.pwb';
% YBus300
% load noise300.mat

option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\TVASummer15Base_renumbered+Basic_SG.pwb';
YBusTVA
% load noiseTVA.mat

tic
centralSE_setup
toc

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

G = full(real(Ybus));
B = full(imag(Ybus));

%tic
while (max(abs(deltax(:,k))) > 1e-4) && (k < maxiter)   
    % Rectangular AC version
    tic
    e = x(1:numbus,k);
    f = [0; x(numbus+1:(2*numbus-1),k)];

    % Form the measurement function h(x^k)
    %tic
    h(:,k) = createhvector_rect(e,f,G,B,numtype,indices,numbus,lines,paraLineIndex); % rectangular
    %htime(k) = toc;
    %tic
    r(:,k) = z-h(:,k);
    %rtime(k) = toc;
    %tic
    J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
    %Jtime(k) = toc;    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    %temp = createHmatrix_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
    %tic
    %tic
    temp = createHmatrix_rect(e,f,G,B,numtype,indices,numbus,buses,lines,paraLineIndex,adjbuses);
    H(:,:,k) = [temp(:,1:numbus) temp(:,numbus+2:2*numbus)];
    %Htime(k) = toc;
   
    % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
    %tic
    Gain(:,:,k) = H(:,:,k).'*(R\H(:,:,k));
    %Gaintime(k) = toc;
    
    % Compute right-hand side
    %tic
    rhs(:,k) = H(:,:,k).'*(R\(z-h(:,k)));
    %rhstime(k) = toc;
    
    % Solve for dx
    %tic
    deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
    %dxtime(k) = toc;
    
    % update x and increase iteration count
    %tic
    x(:,k+1) = x(:,k)+deltax(:,k+1);
    %newxtime(k) = toc;
    
    centralt(k) = toc;
    k = k+1;
end
% mean(htime)
% mean(rtime)
% mean(Jtime)
% mean(Htime)
% mean(Gaintime)
% mean(rhstime)
% mean(dxtime)
% mean(newxtime)
totalt = sum(centralt)
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
therrThreshold = 1e-2;
VerrThreshold = 1e-1;
diffTrueSoln = zeros(numbus*2,1);
diffTrueSoln = centralPWStates - polarStates;
for a = 1:numbus
    if diffTrueSoln(a) > therrThreshold
        errReport = [errReport; 1 a centralPWStates(a) polarStates(a) diffTrueSoln(a)];
    end
end
for a = numbus+1:2*numbus
    if diffTrueSoln(a) > VerrThreshold
        errReport = [errReport; 2 a-numbus centralPWStates(a) polarStates(a) diffTrueSoln(a)];
    end
end
errReport

