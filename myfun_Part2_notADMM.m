function [f2, Gain2, g2, H2, h] = myfun_Part2_notADMM(buses, numbus, lines, lineNum, G, B, x_b)

% x is the system state
% measurements for Partition 1 - [P12; P2; Q12; Q2; V2]
z = [0.888; -0.501; 0.568; -0.286; 0.968];
R = diag([0.008 0.010 0.008 0.010 0.004].^2);

% measurement information
type_b = {'pf'; 'p'; 'qf'; 'q'; 'v'};
indices_b = [1 2 1;
           2 0 0;
           1 2 1;
           2 0 0;
           2 0 0];

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

% x = [ang2; v1; v2]; %slack bus not included
% h is a function of x
% P12, P13, P2, Q12, Q13, Q2, V1, V2
theta = [0; x_b(1); x_b(2)];
V = [x_b(3); x_b(4); x_b(5)];

%% Nonlinear h's
% h1 = x_b(3).^2*(gij(1))-x_b(3)*x_b(4)*...
%            (gij(1)*cos(0-x_b(1))+bij(1)*sin(0-x_b(1)));
%        
% h3 = x_b(4)*(x_b(3)*(G(2,1)*cos(x_b(1)-0)+...
%             B(2,1)*sin(x_b(1)-0))+...
%             x_b(4)*(G(2,2)*cos(x_b(1)-x_b(1))+...
%             B(2,2)*sin(x_b(1)-x_b(1)))+...
%             x_b(5)*(G(2,3)*cos(x_b(1)-x_b(2))+...
%             B(2,3)*sin(x_b(1)-x_b(2))));
% 
% h4 = -x_b(3).^2*(bsi(1)+bij(1))-x_b(3)*x_b(4)*...
%             (gij(1)*sin(0-x_b(1))-bij(1)*cos(0-x_b(1))); 
% 
% h6 = x_b(4)*(x_b(3)*(G(2,1)*sin(x_b(1)-0)-...
%             B(2,1)*cos(x_b(1)-0))+...
%             x_b(4)*(G(2,2)*sin(x_b(1)-x_b(1))-...
%             B(2,2)*cos(x_b(1)-x_b(1)))+...
%             x_b(5)*(G(2,3)*sin(x_b(1)-x_b(2))-...
%             B(2,3)*cos(x_b(1)-x_b(2))));
% 
% h8 = x_b(4);
%  
% h = [h1; h3; h4; h6; h8];

h = createhvector(theta,V,G,B,type_b,indices_b,numbus,buses,lines);

H2 = createHmatrix(theta,V,G,B,type_b,indices_b,numbus,buses,lines);
[Hrow,Hcol] = size(H2); %remove slack column
H2 = H2(:,2:Hcol); %remove slack column

f2 = (z-h).'*(R\(z-h));
Gain2 = H2.'*(R\H2);
g2 = H2.'*(R\(z-h)); %DEBUG: is y a row or column vector? What about c?
