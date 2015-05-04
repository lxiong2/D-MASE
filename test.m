V1 = 1;
V2 = 1;
V5 = 1;
theta1 = 0;
theta2 = 0;
theta5 = 0;
gsi = 0;

bsi12 = 0.0528/2;
z12 = 1/(0.0194+1i*0.0592);
g12 = real(z12);
b12 = imag(z12);

bsi15 = 0.0492/2;
z15 = 1/(0.0540+1i*0.2230);
g15 = real(z15);
b15 = imag(z15);

bsi25 = 0.0346/2;
z25 = 1/(0.0570+1i*0.1739);
g25 = real(z25);
b25 = imag(z25);

% Calculate test h (shouldn't it be zero?)
P12 = V1^2*(gsi+g12) - V1*V2*(g12*cos(theta1-theta2)+b12*sin(theta1-theta2))
P15 = V1^2*(gsi+g15) - V1*V5*(g15*cos(theta1-theta5)+b15*sin(theta1-theta5))
P25 = V2^2*(gsi+g25) - V2*V5*(g25*cos(theta2-theta5)+b25*sin(theta2-theta5))

Q12 = -V1^2*(bsi12+b12) - V1*V2*(g12*sin(theta1-theta2)-b12*cos(theta1-theta2))
Q15 = -V1^2*(bsi15+b15) - V1*V5*(g15*sin(theta1-theta5)-b15*cos(theta1-theta5))
Q25 = -V2^2*(bsi25+b25) - V2*V5*(g25*sin(theta2-theta5)-b25*cos(theta2-theta5))

% Calculate test H
dP12dth1 = V1*V2*(g12*sin(theta1-theta2)-b12*cos(theta1-theta2))
dP12dth2 = -V1*V2*(g12*sin(theta1-theta2)-b12*cos(theta1-theta2))
dP12dV1 = -V2*(g12*cos(theta1-theta2)+b12*sin(theta1-theta2))+2*(g12+gsi)*V1
dP12dV2 = -V2*(g12*cos(theta1-theta2)+b12*sin(theta1-theta2))