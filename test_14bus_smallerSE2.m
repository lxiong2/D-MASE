% IEEE 14-Bus Case
% Measurement data from Korres 2011
% "A distributed multiarea state estimation"

clc
clear all

k = 1;
maxiter = 10;

example_14bus_IEEE_partitions

% flat start for AC
x(:,1) = [ones(numbus2,1); zeros(numbus2-1,1)];
deltax(:,1) = ones(size(x,1),1);

numlines = size(lines4,1);
lineStatus = repmat({'Closed'},[numlines 1]);

YBus_14AC
%YBus_14AC_Part2
%YBus_14AC_Part3
%YBus_14AC_Part4
%Ybus2 = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

% Partial G, B matrices for each partition
% G1 = G(buses,buses); % get submatrix for Partition 1
% B1 = B(buses,buses);
G = G(allbuses2,allbuses2); % get submatrix for Partition 2
B = B(allbuses2,allbuses2);
% G3 = G(allbuses3,allbuses3); % get submatrix for Partition 3
% B3 = B(allbuses3,allbuses3);
% G = G(allbuses4,allbuses4); % get submatrix for Partition 4
% B = B(allbuses4,allbuses4);

while (norm(deltax(:,k)) > 1e-4) && (k < maxiter)
    % Rectangular AC version
    e = x(1:numbus2,k);
    f = [x(numbus2+1:(numbus2+slackIndex2-1),k); 0; x((numbus2+slackIndex2):(2*numbus2-1),k)];

    %h(:,k) = zeros(size(z,1),1);
    % Form the measurement function h(x^k)
    h(:,k) = createhvector_rect(e,f,G,B,alltype2,allindices2,numbus2,allbuses2,lines2); % rectangular
    r(:,k) = allz2-h(:,k);
    J(k) = (allz2-h(:,k)).'*(allR2\(allz2-h(:,k)));
    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    temp = createHmatrix_rect(e,f,G,B,alltype2,allindices2,numbus2,allbuses2,lines2);
    
    % only slackIndex+1:(numbus) instead of slackIndex+1:(2*numbus) when
    % we're looking only at DC
    H(:,:,k) = [temp(:,1:numbus2) temp(:,(numbus2+1):(numbus2+slackIndex2-1)) temp(:,(numbus2+slackIndex2+1):2*numbus2)];

    % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
    Gain(:,:,k) = H(:,:,k).'*(allR2\H(:,:,k));
   
    % Compute right-hand side
    rhs(:,k) = H(:,:,k).'*(allR2\(allz2-h(:,k)));
    
    % Solve for dx
    deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
    
    % update x and increase iteration count
    x(:,k+1) = x(:,k)+deltax(:,k+1);
    k = k+1;
end

x
k

% Convert rectangular state variables to polar form
newe = x(1:numbus2,k);
newf = [x(numbus2+1:(numbus2+slackIndex2-1),k); 0; x((numbus2+slackIndex2):(2*numbus2-1),k)];
newth = zeros(numbus2,1);
newV = zeros(numbus2,1);
for a = 1:numbus2
    newV(a) = sqrt(newe(a)^2+newf(a)^2);
    newth(a) = atan(newf(a)/newe(a));
end

newth
newV
