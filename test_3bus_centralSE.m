clc
clear all

k = 1;
maxiter = 10;

%example_2bus_SG
example_3bus_Abur

%% Polar AC flat start
% x = [th2; th3; V1; V2; V3]

%x(:,1) = [zeros(numbus-1,1); ones(numbus,1)];

%% Rectangular AC flat start
% x = [e1; e2; e3; f2; f3]

x(:,1) = [ones(numbus,1); zeros(numbus-1,1)];

deltax(:,1) = ones(size(x,1),1);
numlines = size(lines,1);
lineStatus = repmat({'Closed'},[numlines 1]);

Ybus = calcYbus(buses, lines(:,1), lines(:,2), lines(:,4), lines(:,5), lines(:,6), lineStatus);
G = real(Ybus);
B = imag(Ybus);

while (norm(deltax(:,k)) > 1e-4) && (k < maxiter)
    % Polar AC version
%     theta = [0; x(1:numbus-1,k)]; % assumes slack bus is bus 1
%     V = x(numbus:(2*numbus-1),k);
    
    % Rectangular AC version
    e = x(1:numbus,k);
    f = [0; x(numbus+1:(2*numbus-1),k)];

    % Form the measurement function h(x^k)
    %h(:,k) = createhvector(theta,V,G,B,type,indices,numbus,buses,lines); % polar
    h(:,k) = createhvector_rect(e,f,G,B,type,indices,numbus,buses,lines); % rectangular
    r(:,k) = z-h(:,k);
    J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
    
    % Form measurement Jacobian H
    % FIX: Test and debug iMeas.m
    % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
    
    % Polar
%     temp = createHmatrix(theta,V,G,B,type,indices,numbus,buses,lines);
%     H(:,:,k) = [temp(:,1:slackIndex-1) temp(:,slackIndex+1:(2*numbus))];
    
    % Rectangular
    temp = createHmatrix_rect(e,f,G,B,type,indices,numbus,buses,lines);
    H(:,:,k) = [temp(:,1:numbus) temp(:,numbus+2:(2*numbus))];
  
    % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
    Gain(:,:,k) = H(:,:,k).'*(R\H(:,:,k));
   
    % Compute right-hand side
    rhs(:,k) = H(:,:,k).'*(R\(z-h(:,k)))
    
    % Solve for dx
    deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
    
    % update x and increase iteration count
    x(:,k+1) = x(:,k) + deltax(:,k+1);
    k = k+1;
    
    %% DC version
%     theta = [0; x(1:(numbus-1),k)]; % assumes slack bus is bus 1
%     V = ones(numbus,1);
% 
%     % Form the measurement function h(x^k)
%     h(:,k) = createhvector_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
%     r(:,k) = z-h(:,k);
%     J(k) = (z-h(:,k)).'*(R\(z-h(:,k)));
%     
%     % Form measurement Jacobian H
%     % FIX: Test and debug iMeas.m
%     % WARNING: Assumed gsi = 0 in realPowerFlowMeas.m
%     temp = createHmatrix_DC2(theta,V,G,B,type,indices,numbus,buses,lines);
%     H(:,:,k) = [temp(:,1:slackIndex-1) temp(:,slackIndex+1:numbus)];
% 
%     % Calculate gain matrix G(x^k) = H.'*R^(-1)*H
%     Gain(:,:,k) = H(:,:,k).'*(R\H(:,:,k));
%    
%     % Compute right-hand side
%     rhs(:,k) = H(:,:,k).'*(R\(z-h(:,k)));
%     
%     % Solve for dx
%     deltax(:,k+1) = Gain(:,:,k)\rhs(:,k);
%     
%     temp2(:,k+1) = [deltax(1:slackIndex-1,k+1); 0; deltax(slackIndex:(numbus-1),k+1)]; % shift indices
%     
%     % update x and increase iteration count
%     x(:,k+1) = x(:,k)+temp2(2:numbus,k+1);
%     k = k+1;
end

x
k

for a = 1:k-1
    condGain(:,a) = cond(Gain(:,:,a));
end

% for a = 1:lineNum
%     ztemp(a) = 1/(lines(a,4)+1i*lines(a,5));
%     gij(a) = real(ztemp(a));
%     bij(a) = imag(ztemp(a));
%     if lines(a,6) ~= 0
%         bsi(a) = 1/(lines(a,6));
%     else bsi(a) = 0;
%     end
% end

%% AC new central measurements
finalx = x(:,k);
% newe = finalx(1:numbus);
% newf = [0; finalx(numbus+1:(2*numbus-1))];
% newz = createhvector_rect(newe,newf,G,B,type,indices,numbus,buses)

newth = [0,0,0,0;
         0,-0.0144481940000000,-0.0145245110000000,-0.0145245090000000;
         0,-0.0209409680000000,-0.0211187040000000,-0.0211186630000000];
newV = [1,1.00001597400000,0.999998362000000,0.999998360000000;
        1,0.994790210000000,0.994807596000000,0.994807597000000;
        1,0.991460477000000,0.991718683000000,0.991718701000000];
newe = [newV(1,:).*cos(newth(1,:));
        newV(2,:).*cos(newth(2,:));
        newV(3,:).*cos(newth(3,:))];
newf = [newV(1,:).*sin(newth(1,:));
        newV(2,:).*sin(newth(2,:));
        newV(3,:).*sin(newth(3,:))];
for k = 1:4
    correcth_pol(:,k) = createhvector(newth(:,k),newV(:,k),G,B,type,indices,numbus,buses,lines);    
    correcth_rect(:,k) = createhvector_rect(newe(:,k),newf(:,k),G,B,type,indices,numbus,buses,lines);
    correctH_pol(:,:,k) = createHmatrix(newth(:,k),newV(:,k),G,B,type,indices,numbus,buses,lines);
    correctH_rect(:,:,k) = createHmatrix_rect(newe(:,k),newf(:,k),G,B,type,indices,numbus,buses,lines);
end
    
%% DC new central measurements
% finalx = x(:,k);
% newth = [0; finalx(1:2)];
% newV = ones(numbus,1);
% newz = createhvector_DC2(newth,newV,G,B,type,indices,numbus,buses,lines)
