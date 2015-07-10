% IEEE 14-Bus Case
% Measurement data from Korres 2011
% "A distributed multiarea state estimation"

% Assumes R = 0 (effectively DC)
% Uses DC equations for h and Haa

% NOTE: for some reason, the 118 PW case's slack is not set to 0.

clc
clear all

k = 1;
maxiter = 20;

option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
filename = 'graph_2parts.txt'; % only matters if option = 3
numParts = 2; % must be at least 2

example_118bus_IEEE_partitions

% flat start for AC
x(:,1) = [ones(numbus,1); zeros(numbus-1,1)];

% flat start for DC
%x(:,1) = ones(numbus,1);
deltax(:,1) = ones(size(x,1),1);

numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

YBus
%YBus_14DC
%Ybus2 = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

while (norm(deltax(:,k)) > 1e-4) && (k < maxiter)
    % Polar AC version
%     theta = [0; x(1:numbus-1,k)]; % assumes slack bus is bus 1
%     V = x(numbus:(2*numbus-1),k);
    
    % Rectangular AC version
    tic
    e = x(1:numbus,k);
    f = [0; x(numbus+1:(2*numbus-1),k)];

    %h(:,k) = zeros(size(z,1),1);
    % Form the measurement function h(x^k)
    %h(:,k) = createhvector_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
    h(:,k) = createhvector_rect(e,f,G,B,type,indices,numbus,buses,lines); % rectangular
    r(:,k) = z-h(:,k);
    J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    %temp = createHmatrix_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
    temp = createHmatrix_rect(e,f,G,B,type,indices,numbus,buses,lines);
    
    % only slackIndex+1:(numbus) instead of slackIndex+1:(2*numbus) when
    % we're looking only at DC
    %H(:,:,k) = [temp(:,1:slackIndex-1) temp(:,slackIndex+1:numbus)];
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

x
k

% Convert rectangular state variables to polar form
newe = x(1:numbus,k);
newf = [0; x(numbus+1:(2*numbus-1),k)];
newth = zeros(numbus,1);
newV = zeros(numbus,1);
for a = 1:numbus
    newV(a) = sqrt(newe(a)^2+newf(a)^2);
    newth(a) = atan(newf(a)/newe(a));
end

newth
newV
