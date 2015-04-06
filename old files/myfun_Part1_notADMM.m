function [f1, Gain1, g1, H1, h] = myfun_Part1_notADMM(buses, numbus, lines, lineNum, G, B, x_a)

% x is the system state
% measurements for Partition 1 - [P12; P13; Q12; Q13; V1]
% z = [0.888; 1.173; 0.568; 0.663; 1.006];
% R = diag([0.008 0.008 0.008 0.008 0.004].^2);

% measurement information
type_a = {'pf'; 'pf'; 'qf'; 'qf'; 'v'};
indices_a = [1 2 1;
    1 3 1;
    1 2 1;
    1 3 1;
    1 0 0];

% test only
%z = [0.888; 1.173; -0.501; 0.568; 0.663; -0.286; 1.006; 0.968];
%R = diag([0.008 0.008 0.010 0.008 0.008 0.010 0.004 0.004]);

for a = 1:lineNum
    ztemp(a) = 1/(lines(a,4)+1i*lines(a,5));
    gij(a) = real(ztemp(a));
    bij(a) = imag(ztemp(a));
    if lines(a,6) ~= 0
        bsi(a) = 1/(lines(a,6));
    else bsi(a) = 0;
    end
end

% x = [ang2; ang3; v1; v2; v3]; %slack bus not included
% h is a function of x
% P12, P13, P2, Q12, Q13, Q2, V1, V2

theta = [0; x_a(1); x_a(2)];
V = [x_a(3); x_a(4); x_a(5)];

%% Nonlinear h's
% h1 = x_a(3).^2*(gij(1))-x_a(3)*x_a(4)*...
%            (gij(1)*cos(0-x_a(1))+bij(1)*sin(0-x_a(1)));
% 
% h2 = x_a(3).^2*(gij(2))-x_a(3)*x_a(5)*...
%             (gij(2)*cos(0-x_a(2))+bij(2)*sin(0-x_a(2)));
% 
% h4 = -x_a(3).^2*(bsi(1)+bij(1))-x_a(3)*x_a(4)*...
%             (gij(1)*sin(0-x_a(1))-bij(1)*cos(0-x_a(1))); 
% 
% h5 = -x_a(3).^2*(bsi(2)+bij(2))-x_a(3)*x_a(5)*...
%             (gij(2)*sin(0-x_a(2))-bij(2)*cos(0-x_a(2)));
% 
% h7 = x_a(3);
%  
% h = [h1; h2; h4; h5; h7];
h = createhvector(theta,V,G,B,type_a,indices_a,numbus,buses,lines);

H1 = createHmatrix(theta,V,G,B,type_a,indices_a,numbus,buses,lines);
[Hrow,Hcol] = size(H1);
H1 = H1(:,2:Hcol); %remove slack column

f1 = (z-h).'*(R\(z-h));
Gain1 = H1.'*(R\H1);
g1 = H1.'*(R\(z-h)); %DEBUG: is y a row or column vector? What about c?
