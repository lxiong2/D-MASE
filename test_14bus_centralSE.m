% IEEE 14-Bus Case
% Measurement data from Korres 2011
% "A distributed multiarea state estimation"

% Assumes R = 0 (effectively DC)
% Uses DC equations for h and Haa

clc
clear all

k = 1;
maxiter = 10;

example_14bus_IEEE

% flat start for DC
x(:,1) = zeros(numbus-1,1);
deltax(:,1) = ones(size(x,1),1);

numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

YBus_14DC
%Ybus2 = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

while (norm(deltax(:,k)) > 1e-4) && (k < maxiter)
    theta = [0; x(1:(numbus-1),k)]; % assumes slack bus is bus 1
    V = ones(numbus,1);

    %h(:,k) = zeros(size(z,1),1);
    % Form the measurement function h(x^k)
    h(:,k) = createhvector_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
    r(:,k) = z-h(:,k);
    J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    temp = createHmatrix_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
    
    % only slackIndex+1:(numbus) instead of slackIndex+1:(2*numbus) because
    % we're looking only at DC
    H(:,:,k) = [temp(:,1:slackIndex-1) temp(:,slackIndex+1:numbus)];

    % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
    Gain(:,:,k) = H(:,:,k).'*(R\H(:,:,k));
   
    % Compute right-hand side
    rhs(:,k) = H(:,:,k).'*(R\(z-h(:,k)));
    
    % Solve for dx
    deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
    
    temp2(:,k+1) = [deltax(1:slackIndex-1,k+1); 0; deltax(slackIndex:(numbus-1),k+1)]; % shift indices
    
    % update x and increase iteration count
    x(:,k+1) = x(:,k)+temp2(2:numbus,k+1);
    k = k+1;
end

x
k

% for a = 1:k-1
%     condGain(:,a) = cond(Gain(:,:,a));
% end
% 
% for a = 1:lineNum
%     ztemp(a) = 1/(lines(a,4)+1i*lines(a,5));
%     gij(a) = real(ztemp(a));
%     bij(a) = imag(ztemp(a));
%     if lines(a,6) ~= 0
%         bsi(a) = 1/(lines(a,6));
%     else bsi(a) = 0;
%     end
% end
% 
% % x = [th2; th3; V1; V2; V3]
finalx = x(:,k);
newth = [0; finalx(1:13)];
newV = ones(numbus,1);
newz = createhvector_DC2(newth,newV,G,B,type,indices,numbus,buses,lines)