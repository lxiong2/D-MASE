% Traditional central state estimation plus bad data detection (using
% largest normalized residual test)

clc
clear all
close all
format long

centralt = 0;
option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS

% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb';
% YBus14
% load badData14.mat

casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\SouthPensacola42_v01_DC.pwb';
YBusPensacola
load badDataPensacola.mat
%load noisePensacola.mat

% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 57 bus.pwb';
% YBus57
% load noise57.mat

% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_2parts.pwb';
% %casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 118 Bus_test (2).pwb';
% YBus118
% %YBus118_test
% % load noise118_test.mat
% load noise118.mat

% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE300Bus.pwb';
% YBus300
% load noise300.mat

% casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\TVASummer15Base_renumbered+Basic+noBusShunts.pwb';
% YBusTVA
% load noiseTVA.mat

tic
centralSE_setup
toc
% 
%% Add Gaussian noise to measurements
for a = 1:size(z,1)
    %if (indices(a,1) ~= globalSlack) && (indices(a,2) ~= globalSlack)
        z(a) = z(a)*(1+noise(a,4));
    %end
end

lineStatus = repmat({'Closed'},[numlines 1]);

G = full(real(Ybus));
B = full(imag(Ybus));

r_largest = 4;
badthres = 3; %bad data detection threshold (c) - user defined
BDD_iter = 1;

badMeas = [];

while r_largest > badthres
    % flat start for AC
    x(:,1) = [ones(numbus,1); zeros(numbus-1,1)];
    deltax(:,1) = ones(size(x,1),1);
    k = 1;
    maxiter = 20;
    R = diag(0.01^2*ones(1,size(type,1)));
    %% Solve central AC state estimation in rectangular form
    while (max(abs(deltax(:,k))) > 1e-4) && (k < maxiter)   
        tic
        e = x(1:numbus,k);
        f = [0; x(numbus+1:(2*numbus-1),k)];

        % Form the measurement function h(x^k)
        h(:,k) = createhvector_rect(e,f,G,B,numtype,indices,numbus,lines,paraLineIndex); % rectangular
        r(:,k) = z-h(:,k);
        J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
        % Form measurement Jacobian H
        % FIX: Test and debug iMeas.m
        % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
        temp = createHmatrix_rect(e,f,G,B,numtype,indices,numbus,buses,lines,paraLineIndex,adjbuses);
        H(:,:,k) = [temp(:,1:numbus) temp(:,numbus+2:2*numbus)];

        % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
        Gain(:,:,k) = H(:,:,k).'*(R\H(:,:,k));

        % Compute right-hand side
        rhs(:,k) = H(:,:,k).'*(R\(z-h(:,k)));

        % Solve for dx
        deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);

        % update x and increase iteration count
        x(:,k+1) = x(:,k)+deltax(:,k+1);

        centralt(k) = toc;
        k = k+1;    
    end
    %% Bad data detection using Largest Normalized Residual Test
    bigK = H(:,:,k-1)*inv(Gain(:,:,k-1))*H(:,:,k-1).'*inv(R); %hat matrix
    bigS = eye(size(z,1))-bigK; %residual sensitivity matrix
    Omega = bigS*R; %residual covariance matrix

    % Perform largest normalized residual test
    r_norm = abs(r(:,k-1))./sqrt(diag(Omega)); %calc all normalized residuals
    [r_largest,ind_largest] = max(r_norm); % find largest normalized residual
    if r_largest > badthres %if r_largest > c
        newz = z(ind_largest)-(R(ind_largest,ind_largest)/Omega(ind_largest,ind_largest)*(z(ind_largest)-h(ind_largest,k-1)));
        badMeas = [badMeas; indices(ind_largest,:) ind_largest z(ind_largest) newz];
        z(ind_largest) = newz;
    end
    BDD_iter = BDD_iter + 1;
end
totalt = sum(centralt)
badMeas
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
VerrThreshold = 1e-2;
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
