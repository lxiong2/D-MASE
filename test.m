%% Debug 118 ADMM H2

clc
clear all

load('centralH_iter1.mat')

numbus = 118;
slack2 = 69;
buses2 = [24; (68:112).'; 116; 118];
tiebuses2 = [23; 47; 49; 65];
allbuses2 = sort([buses2; tiebuses2]);

newH = zeros(size(H,1),numbus*2);
newH(:,1:numbus) = H(:,1:numbus);
newH(:,numbus+1:numbus*2) = [H(:,numbus+(1:slack2-1)) zeros(size(H,1),1) H(:,numbus+(slack2+1:numbus))]

correctH2 = [newH(435:734,allbuses2,1) newH(435:734,numbus+allbuses2,1)]

load('correctH2.mat')
firstH2 = correctH2;
load('myH2.mat')
secH2 = myH2;
diff = firstH2 - secH2

%% Check how parallel power flows are calculated
% V1 = 1;
% V2 = 1.044999957975790;
% V5 = 1.028092514790582;
% 
% theta1 = 0;
% theta2 = -0.086707362007296;
% theta5 = -0.154698697268199;
% 
% gsi = 0;
% 
% bsi12 = 0.0528/2;
% z12 = 1/(0.0194+1i*0.0592);
% g12 = real(z12);
% b12 = imag(z12);
% 
% bsi15 = 0.0492/2;
% z15 = 1/(0.0540+1i*0.2230);
% g15 = real(z15);
% b15 = imag(z15);
% 
% bsi25 = 0.0346/2;
% z25 = 1/(0.05695+1i*0.17388);
% g25 = real(z25);
% b25 = imag(z25);
% 
% % Calculate test h (shouldn't it be zero?)
% P12 = V1^2*(gsi+g12) - V1*V2*(g12*cos(theta1-theta2)+b12*sin(theta1-theta2))
% P15 = V1^2*(gsi+g15) - V1*V5*(g15*cos(theta1-theta5)+b15*sin(theta1-theta5))
% P25 = V2^2*(gsi+g25) - V2*V5*(g25*cos(theta2-theta5)+b25*sin(theta2-theta5))
% 
% Q12 = -V1^2*(bsi12+b12) - V1*V2*(g12*sin(theta1-theta2)-b12*cos(theta1-theta2))
% Q15 = -V1^2*(bsi15+b15) - V1*V5*(g15*sin(theta1-theta5)-b15*cos(theta1-theta5))
% Q25 = -V2^2*(bsi25+b25) - V2*V5*(g25*sin(theta2-theta5)-b25*cos(theta2-theta5))
% 
% % Calculate test H
% dP12dth1 = V1*V2*(g12*sin(theta1-theta2)-b12*cos(theta1-theta2))
% dP12dth2 = -V1*V2*(g12*sin(theta1-theta2)-b12*cos(theta1-theta2))
% dP12dV1 = -V2*(g12*cos(theta1-theta2)+b12*sin(theta1-theta2))+2*(g12+gsi)*V1
% dP12dV2 = -V2*(g12*cos(theta1-theta2)+b12*sin(theta1-theta2))