% IEEE 14-Bus Case
% Measurement data from Korres 2011
% "A distributed multiarea state estimation"

clc
clear all

k = 1;
maxiter = 10;

example_14bus_IEEE_partitions

% flat start for AC
x(:,1) = [ones(numbus4,1); zeros(numbus4-1,1)];
deltax(:,1) = ones(size(x,1),1);

numlines = size(lines4,1);
lineStatus = repmat({'Closed'},[numlines 1]);

%YBus_14AC_Part2
%YBus_14AC_Part3
YBus_14AC_Part4
%Ybus2 = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

% Partial G, B matrices for each partition
% G1 = G(buses,buses); % get submatrix for Partition 1
% B1 = B(buses,buses);
% G2 = G(allbuses2,allbuses2); % get submatrix for Partition 2
% B2 = B(allbuses2,allbuses2);
% G3 = G(allbuses3,allbuses3); % get submatrix for Partition 3
% B3 = B(allbuses3,allbuses3);
% G4 = G(allbuses4,allbuses4); % get submatrix for Partition 4
% B4 = B(allbuses4,allbuses4);

while (norm(deltax(:,k)) > 1e-4) && (k < maxiter)
    % Rectangular AC version
    x
    e = x(1:numbus4,k)
    f = [x(numbus4+1:(numbus4+slackIndex4-1),k); 0; x((numbus4+slackIndex4):(2*numbus4-1),k)]

    %h(:,k) = zeros(size(z,1),1);
    % Form the measurement function h(x^k)
    h(:,k) = createhvector_rect(e,f,G,B,alltype4,allindices4,numbus4,allbuses4,lines4) % rectangular
    r(:,k) = allz4-h(:,k);
    J(k) = (allz4-h(:,k)).'*(allR4\(allz4-h(:,k)));
    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    temp = createHmatrix_rect(e,f,G,B,alltype4,allindices4,numbus4,allbuses4,lines4)
    
    % only slackIndex+1:(numbus) instead of slackIndex+1:(2*numbus) when
    % we're looking only at DC
    H(:,:,k) = [temp(:,1:numbus4) temp(:,(numbus4+1):(numbus4+slackIndex4-1)) temp(:,(numbus4+slackIndex4+1):2*numbus4)]

    % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
    Gain(:,:,k) = H(:,:,k).'*(allR4\H(:,:,k));
   
    % Compute right-hand side
    rhs(:,k) = H(:,:,k).'*(allR4\(allz4-h(:,k)));
    
    % Solve for dx
    deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
    
    % update x and increase iteration count
    x(:,k+1) = x(:,k)+deltax(:,k+1);
    k = k+1;
end

x
k

% Convert rectangular state variables to polar form
newe = x(1:numbus4,k);
newf = [x(numbus4+1:(numbus4+slackIndex4-1),k); 0; x((numbus4+slackIndex4):(2*numbus4-1),k)];
newth = zeros(numbus4,1);
newV = zeros(numbus4,1);
for a = 1:numbus4
    newV(a) = sqrt(newe(a)^2+newf(a)^2);
    newth(a) = atan(newf(a)/newe(a));
end

newth
newV
