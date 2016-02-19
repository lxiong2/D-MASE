% 3-bus example from Ali Abur's Power System State Estimation book

buses = [1; 2];
slackIndex = 1;
numbus = size(buses,1);

% AC line information
lines = [1 2 1 0.03 0.04 0];
     
% DC line information
% lines = [1 2 1 0 0.04 0];

lineNum = size(lines,1);

% list of adjacent buses
adjbuses = [2;
            1];

% x = [ang2; V1; V2]; %slack bus not included

%% Example from ECE 6320 notes
z = [1.0485^2;
     0.8623^2;
     4.631;
     -1.05;
     -4.045]

Rdiag = [0.02 0.02 0.04 0.04 0.04].^2;
R = diag(Rdiag);

% measurement types
type = {'v'; 'v'; 'pf'; 'qf'; 'p'};
indices = [1 0 0;
           2 0 0;
           1 2 1;
           2 1 1;
           2 0 0];
% 
%% Perfect AC measurements after running power flow
% z = [1.032605774;
%      0.143474275;
%      1.032605767;
%      0.143474281;
%      -1;
%      -0.1;
%      1;
%      0.963993186]
%  
% Rdiag = [0.04 0.04 0.04 0.04 0.04 0.04 0.02 0.02].^2;
% R = diag(Rdiag);
% 
% type = {'pf'; 'qf'; 'p'; 'q'; 'p'; 'q'; 'v'; 'v'};
% indices = [1 2 1;
%            1 2 1;
%            1 0 0;
%            1 0 0;
%            2 0 0;
%            2 0 0;
%            1 0 0;
%            2 0 0];
       
%% Decentralized case
% % allbuses1 = [1; 2]; %x = [th1; th2'; th3; V1; V2'; V3] for AC
% % AC
% % allz1 = [z(1:2); z(4:5); z(7)]; 
% % allR1 = diag([Rdiag(1:2) Rdiag(4:5) Rdiag(7)]);
% % alltype1 = [type(1:2); type(4:5); type(7)];
% % allindices1 = [indices(1:2,:);
% %                indices(4:5,:);
% %                indices(7,:)];
% % DC
% % allz1 = [z(1:2)]; 
% % allR1 = diag([Rdiag(1:2)]);
% % alltype1 = [type(1:2)];
% % allindices1 = [indices(1:2,:)];
% % 
% % allbuses2 = [1; 2; 3]; %x = [th1'; th2; th3'; V1'; V2; V3'] for AC
% % AC
% % allz2 = [z(1); z(3); z(4); z(6); z(8)];
% % allR2 = diag([Rdiag(1) Rdiag(3) Rdiag(4) Rdiag(6) Rdiag(8)]);
% % alltype2 = [type(1); type(3); type(4); type(6); type(8)];
% % allindices2 = [indices(1,:);
% %                indices(3,:);
% %                indices(4,:);
% %                indices(6,:);
% %                indices(8,:)];
% % DC
% % allz2 = [z(1); z(3)];
% % allR2 = diag([Rdiag(1) Rdiag(3)]);
% % alltype2 = [type(1); type(3)];
% % allindices2 = [indices(1,:);
% %                indices(3,:)];