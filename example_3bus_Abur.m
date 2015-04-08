% 3-bus example from Ali Abur's Power System State Estimation book

buses = [1; 2; 3];
slackIndex = 1;
numbus = size(buses,1);

% AC line information
lines = [1 2 1 0.01 0.03 0;
         1 3 1 0.02 0.05 0;
         2 3 1 0.03 0.08 0];
     
% DC line information
% lines = [1 2 1 0 0.03 0;
%          1 3 1 0 0.05 0;
%          2 3 1 0 0.08 0];

lineNum = size(lines,1);

% list of adjacent buses
adjbuses = [2 3;
            1 3;
            1 2];

% x = [ang2; ang3; V1; V2; V3]; %slack bus not included

% Given measurements in the book
%z = [0.888; 1.173; -0.501; 0.568; 0.663; -0.286; 1.006; 0.968];

% Perfect AC measurements after running power flow
%z = [0.892991980906214;1.17102446192718;-0.495974956974634;0.558821689897716;0.667618708515178;-0.297749528729336;0.999629257855364;0.974156071583298]

z = [0.4864415159668960;
     0.4196836121598750;
     -0.4000000000000000;
     0.0144776824615491;
     0.0020941787076120;
     0.0000000000000000;
%      % Polar V measurements
%      1.0000000000000000;
%      0.9948061840940000]
     % Rectangular V measurements
     1.0000000000000000^2;
     0.9948061840940000^2]

% After running SE on perfect AC measurements
%z = [0.484110867410053;0.420765689413069;-0.402714233939197;0.00990113466041009;0.00418283886383009;-0.00511898351369013;0.997499689048022;0.997308195081827]

% After running DC SE on initial z
%z = [0.892694448242691;1.17086348598755;-0.495665187591478;0.0119535506688493;0.0342730325704750;0.0182588400213799;1;1]

% Perfect DC measurements
%z = [0.909166263643888;1.16340425048040;-0.473990876460978;0.0123987494242215;0.0338377362508950;0.162172295728205;1;1]
% z = [48.12500097177691/100;
%      41.87499962426954/100
%      -40/100;
%      0/100;
%      0/100;
%      0/100;
%      1.000000000000;
%      1.000000000000]

Rdiag = [0.008 0.008 0.010 0.008 0.008 0.010 0.004 0.004].^2;
R = diag(Rdiag);

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
       
%% Decentralized case
allbuses1 = [1; 2; 3]; %x = [th1; th2'; th3; V1; V2'; V3] for AC
% AC
allz1 = [z(1:2); z(4:5); z(7)]; 
allR1 = diag([Rdiag(1:2) Rdiag(4:5) Rdiag(7)]);
alltype1 = [type(1:2); type(4:5); type(7)];
allindices1 = [indices(1:2,:);
               indices(4:5,:);
               indices(7,:)];
% DC
% allz1 = [z(1:2)]; 
% allR1 = diag([Rdiag(1:2)]);
% alltype1 = [type(1:2)];
% allindices1 = [indices(1:2,:)];

allbuses2 = [1; 2; 3]; %x = [th1'; th2; th3'; V1'; V2; V3'] for AC
% AC
allz2 = [z(1); z(3); z(4); z(6); z(8)];
allR2 = diag([Rdiag(1) Rdiag(3) Rdiag(4) Rdiag(6) Rdiag(8)]);
alltype2 = [type(1); type(3); type(4); type(6); type(8)];
allindices2 = [indices(1,:);
               indices(3,:);
               indices(4,:);
               indices(6,:);
               indices(8,:)];
% DC
% allz2 = [z(1); z(3)];
% allR2 = diag([Rdiag(1) Rdiag(3)]);
% alltype2 = [type(1); type(3)];
% allindices2 = [indices(1,:);
%                indices(3,:)];