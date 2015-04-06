clc
clear all

buses = [1; 2; 3];
slackIndex = 1;
numbus = size(buses,1);

k = 1;
maxiter = 10;

% flat start
% x = [ang2; ang3; V1; V2; V3]; %slack bus not included
x(:,1) = [0; 0; 1; 1; 1];
deltax(:,1) = [1; 1; 1; 1; 1];

z = [0.888; 1.173; -0.501; 0.568; 0.663; -0.286; 1.006; 0.968];
R = diag([0.008 0.008 0.010 0.008 0.008 0.010 0.004 0.004].^2);

lines = [1 2 1 0.01 0.03 0;
         1 3 1 0.02 0.05 0;
         2 3 1 0.03 0.08 0];
lineNum = size(lines,1);

Ybus = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), {'Closed';'Closed';'Closed'});
G = real(Ybus);
B = imag(Ybus);

% measurement types
type = {'pf'; 'pf'; 'p'; 'qf'; 'qf'; 'q'; 'v'; 'v'};
indices = [1 2 1;
           1 3 1;
           2 0 0;
           1 2 1;
           1 3 1;
           2 0 0;
           1 0 0;
           2 0 0];

while (norm(deltax(:,k)) > 1e-4) && (k < maxiter)
    theta = [0; x(1:2,k)];
    V = x(3:5,k);

    %h(:,k) = zeros(size(z,1),1);
    % Form the measurement function h(x^k)
    h(:,k) = createhvector(theta,V,G,B,type,indices,numbus,buses,lines);
    r(:,k) = z-h(:,k);
    J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    temp = createHmatrix(theta,V,G,B,type,indices,numbus,buses,lines);
    H(:,:,k) = [temp(:,1:slackIndex-1) temp(:,slackIndex+1:(2*numbus))];

    % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
    Gain(:,:,k) = H(:,:,k).'*(R\H(:,:,k));
   
    % Compute right-hand side
    rhs(:,k) = H(:,:,k).'*(R\(z-h(:,k)));
    
    % Solve for dx
    deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
    
    temp2(:,k+1) = [deltax(1:slackIndex-1,k+1); 0; deltax(slackIndex:(2*numbus-1),k+1)]; % shift indices
    
    % update x and increase iteration count
    x(:,k+1) = x(:,k)+temp2(2:6,k+1);
    k = k+1;
end

x
k

for a = 1:k-1
    condGain(:,a) = cond(Gain(:,:,a));
end

for a = 1:lineNum
    ztemp(a) = 1/(lines(a,4)+1i*lines(a,5));
    gij(a) = real(ztemp(a));
    bij(a) = imag(ztemp(a));
    if lines(a,6) ~= 0
        bsi(a) = 1/(lines(a,6));
    else bsi(a) = 0;
    end
end

% x = [th2; th3; V1; V2; V3]
finalx = x(:,k);
P23 = finalx(4)^2*(gij(3))-finalx(4)*finalx(5)*(gij(3)*cos(finalx(1)-finalx(2))+bij(3)*sin(finalx(1)-finalx(2)));
Q23 = -finalx(4)^2*(bij(3))-finalx(4)*finalx(5)*(gij(3)*sin(finalx(1)-finalx(2))-bij(3)*cos(finalx(1)-finalx(2)));