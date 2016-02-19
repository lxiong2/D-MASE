% IEEE 14-bus case
% see topology and measurement data from Korres 2011 
% "A distributed multiarea state estimation" 

buses = (1:14).';
slackIndex = 1;
numbus = size(buses,1);

%% Line Information
% AC line data
lines = [1 2 1 0.01938 0.05917 0.0528;
         1 5 1 0.05403 0.22304 0.0492;
         2 3 1 0.04699 0.19797 0.0438;
         2 4 1 0.05811 0.17632 0.034;
         2 5 1 0.05695 0.17388 0.0346;
         3 4 1 0.06701 0.17103 0.0128;
         4 5 1 0.01335 0.04211 0;
         4 7 1 0 0.20912 0;
         4 9 1 0 0.55618 0;
         5 6 1 0 0.25202 0;
         6 11 1 0.09498 0.1989 0;
         6 12 1 0.12291 0.25581 0;
         6 13 1 0.06615 0.13027 0;
         7 8 1 0 0.17615 0;
         7 9 1 0 0.11001 0;
         9 10 1 0.03181 0.0845 0;
         9 14 1 0.12711 0.27038 0;
         10 11 1 0.08205 0.19207 0;
         12	13 1 0.22092 0.19988 0;
         13 14 1 0.17093 0.34802 0];

% % Actual DC approximation
% lines = [1 2 1 0 0.05917 0;
%          1 5 1 0 0.22304 0;
%          2 3 1 0 0.19797 0;
%          2 4 1 0 0.17632 0;
%          2 5 1 0 0.17388 0;
%          3 4 1 0 0.17103 0;
%          4 5 1 0 0.04211 0;
%          4 7 1 0 0.20912 0;
%          4 9 1 0 0.55618 0;
%          5 6 1 0 0.25202 0;
%          6 11 1 0 0.1989 0;
%          6 12 1 0 0.25581 0;
%          6 13 1 0 0.13027 0;
%          7 8 1 0 0.17615 0;
%          7 9 1 0 0.11001 0;
%          9 10 1 0 0.0845 0;
%          9 14 1 0 0.27038 0;
%          10 11 1 0 0.19207 0;
%          12	13 1 0 0.19988 0;
%          13 14 1 0 0.34802 0];

lineNum = size(lines,1);

% list of adjacent buses
adjbuses = [2 5 0 0 0;
            1 3 4 5 0;
            2 4 0 0 0;
            2 3 5 7 9;
            1 2 4 6 0;
            5 11 12 13 0;
            4 8 9 0 0;
            7 0 0 0 0;
            4 7 10 14 0;
            9 11 0 0 0; 
            6 10 0 0 0;
            6 13 0 0 0;
            6 12 14 0 0;
            9 13 0 0 0];

%% Measurement information


%% PowerWorld AC; took out measurement P5-4        
%z = [z1; z2; z3; z4; zc1; zc2; zc3; zc4]
% z = [% z1
%     0;
%     0.0669694400596115;
%     0.0613001026553834;
%     -0.00566933740422815;
%     0.128269542714995;
%     -0.0207036876479782;
%     % z2
%     -0.0855336586785135;
%     -0.0449372436711084;
%     0.00510914499216659;
%     -0.000200000000000006;
%     % z3
%     -0.0212491095769634;
%     0.0128554109939716;
%     0.0159324183882003;
%     0.0186014676912864;
%     0.00266904930308611;
%     -0.0132633690851142;
%     % z4
%     -0.0426149573330085;
%     -0.000155166821578699;
%     0.0159161648500781;
%     % zc1
%     -0.116385445977553;
%     % zc2
%     0.0207036876479782;
%     0.00201854232560333;
%     -0.00309060266656325;
%     -0.0635014622900104;
%     -0.0855336586785135;
%     % zc3
%     0.0186805449148368;
%     -0.00258997207953567;
%     -0.0212491095769634;
%     % zc4
%     -0.00835526994049485;
%     -0.0345967097649149;
%     -0.0426149573330085]

%% PowerWorld DC R = 0, C = 0, X = actual; took out measurement P5-4
% z = [% Area 1
%      0;
%      1.478805704;
%      0.711194242;
%      0.409039747;
%      2.19;
%      % Area 2
%      -0.226179389;
%      -0.241497607;
%      0.289850804;
%      0;
%      % Area 3
%      -0.264683847;
%      0.063047605;
%      0.075451451;
%      0.170336919;
%      0.01445145;
%      -0.061;
%      % Area 4
%      -0.277376142;
%      0.061952399;
%      0.09921164;
%      % Boundary 1
%      -0.076;
%      % Boundary 2
%      -0.623398013;
%      0.166313222;
%      0.289850804;
%      -0.942;
%      -0.226179389;
%      % Boundary 3
%      0.049788364;
%      -0.135;
%      -0.264683847;
%      % Boundary 4
%      -0.028047605;
%      -0.149;
%      -0.277376142];

% type = {% Area 1
%         'th'; 'pf'; 'pf'; 'pf'; 'p';
%         % Area 2
%         'th'; 'pf'; 'pf'; 'pf';
%         % Area 3
%         'th'; 'pf'; 'pf'; 'pf'; 'pf'; 'p';
%         % Area 4
%         'th'; 'pf'; 'pf';
%         % Boundary 1
%         'p';
%         % Boundary 2
%         'pf'; 'pf'; 'pf'; 'p'; 'th';
%         % Boundary 3
%         'pf'; 'p'; 'th';
%         % Boundary 4
%         'pf'; 'p'; 'th'};
% 
% indices = [% Area 1
%             1 0 0;
%             1 2 1;
%             1 5 1;
%             2 5 1;
%             1 0 0;
%             % Area 2
%             3 0 0;
%             3 4 1;
%             4 7 1;
%             7 8 1;
%             % Area 3
%             6 0 0;
%             6 11 1;
%             6 12 1;
%             6 13 1;
%             12 13 1;
%             12 0 0;
%             % Area 4
%             9 0 0;
%             9 10 1;
%             9 14 1;
%             % Boundary 1
%             5 0 0;
%             % Boundary 2
%             4 5 1;
%             4 9 1;
%             7 9 1;
%             3 0 0;
%             3 0 0;
%             % Boundary 3
%             13 14 1;
%             13 0 0;
%             6 0 0;
%             % Boundary 4
%             10 11 1;
%             14 0 0;
%             9 0 0];

R = diag(0.01^2*ones(1,size(z,1)));

% Decentralized case: include boundary measurements for each area
allbuses1 = [1; 2; 4; 5; 6]; %indices of x1
allz1 = [z(1:5); z(19)]; 
allR1 = diag(0.01^2*ones(1,size(allz1,1)));
alltype1 = [type(1:5); type(19)]; 
allindices1 = [indices(1:5,:); indices(19,:)]; 

allbuses2 = [2; 3; 4; 5; 7; 8; 9];
allz2 = [z(6:9); z(20:24)];
allR2 = diag(0.01^2*ones(1,size(allz2,1)));
alltype2 = [type(6:9); type(20:24)];
allindices2 = [indices(6:9,:); indices(20:24,:)];

allbuses3 = [6; 11; 12; 13; 14];
allz3 = [z(10:15); z(25:27)];
allR3 = diag(0.01^2*ones(1,size(allz3,1)));
alltype3 = [type(10:15); type(25:27)];
allindices3 = [indices(10:15,:); indices(25:27,:)];

allbuses4 = [9; 10; 11; 13; 14];
allz4 = [z(16:18); z(28:30)];
allR4 = diag(0.01^2*ones(1,size(allz4,1)));
alltype4 = [type(16:18); type(28:30)];
allindices4 = [indices(16:18,:); indices(28:30,:)];

%% PowerWorld DC R = 0, C = 0, X = actual; took out measurement P5-4 AND angle measurements
% Central solution converges just fine; however, decentralized solution 
% is not even close to central; possibly not observable? 
% Not sure why it isn't similar even at 100 iterations

% z = [% Area 1
%      1.478805704;
%      0.711194242;
%      0.409039747;
%      2.19;
%      % Area 2
%      -0.241497607;
%      0.289850804;
%      0;
%      % Area 3
%      0.063047605;
%      0.075451451;
%      0.170336919;
%      0.01445145;
%      -0.061;
%      % Area 4
%      0.061952399;
%      0.09921164;
%      % Boundary 1
%      -0.076;
%      % Boundary 2
%      -0.623398013;
%      0.166313222;
%      0.289850804;
%      -0.942;
%      % Boundary 3
%      0.049788364;
%      -0.135;
%      % Boundary 4
%      -0.028047605;
%      -0.149];
%         
% type = {% Area 1
%         'pf'; 'pf'; 'pf'; 'p';
%         % Area 2
%         'pf'; 'pf'; 'pf';
%         % Area 3
%         'pf'; 'pf'; 'pf'; 'pf'; 'p';
%         % Area 4
%         'pf'; 'pf';
%         % Boundary 1
%         'p';
%         % Boundary 2
%         'pf'; 'pf'; 'pf'; 'p';
%         % Boundary 3
%         'pf'; 'p';
%         % Boundary 4
%         'pf'; 'p'};
% 
% indices = [% Area 1
%             1 2 1;
%             1 5 1;
%             2 5 1;
%             1 0 0;
%             % Area 2
%             3 4 1;
%             4 7 1;
%             7 8 1;
%             % Area 3
%             6 11 1;
%             6 12 1;
%             6 13 1;
%             12 13 1;
%             12 0 0;
%             % Area 4
%             9 10 1;
%             9 14 1;
%             % Boundary 1
%             5 0 0;
%             % Boundary 2
%             4 5 1;
%             4 9 1;
%             7 9 1;
%             3 0 0;
%             % Boundary 3
%             13 14 1;
%             13 0 0;
%             % Boundary 4
%             10 11 1;
%             14 0 0];
%         
% R = diag(0.01^2*ones(1,size(z,1)));
% 
% % Decentralized case: include boundary measurements for each area
% allbuses1 = [1; 2; 4; 5; 6]; %indices of x1
% allz1 = [z(1:4); z(15)]; 
% allR1 = diag(0.01^2*ones(1,size(allz1,1)));
% alltype1 = [type(1:4); type(15)]; 
% allindices1 = [indices(1:4,:); indices(15,:)]; 
% 
% allbuses2 = [2; 3; 4; 5; 7; 8; 9];
% allz2 = [z(5:7); z(16:19)];
% allR2 = diag(0.01^2*ones(1,size(allz2,1)));
% alltype2 = [type(5:7); type(16:19)];
% allindices2 = [indices(5:7,:); indices(16:19,:)];
% 
% allbuses3 = [6; 11; 12; 13; 14];
% allz3 = [z(8:12); z(20:21)];
% allR3 = diag(0.01^2*ones(1,size(allz3,1)));
% alltype3 = [type(8:12); type(20:21)];
% allindices3 = [indices(8:12,:); indices(20:21,:)];
% 
% allbuses4 = [9; 10; 11; 13; 14];
% allz4 = [z(13:14); z(22:23)];
% allR4 = diag(0.01^2*ones(1,size(allz4,1)));
% alltype4 = [type(13:14); type(22:23)];
% allindices4 = [indices(13:14,:); indices(22:23,:)];
             
%% PowerWorld DC X = 1
% z = [0;
%     1.08824709100000;
%     1.10175285400000;
%     0.0135057633500000;
%     2.19000000000000;
%     0.510988473300000;
%     -1.82149419500000;
%     -0.208752867600000;
%     0.116243285700000;
%     0;
%     -1.63002300100000;
%     0.125068300600000;
%     0.117400614500000;
%     0.173801228300000;
%     0.0564006138100000;
%     -0.0610000000000000;
%     -1.84522789900000;
%     -6.82968706300000e-05;
%     0.0537981671700000;
%     -0.0760000000000000;
%     -0.510988473300000;
%     0.232486571500000;
%     0.116243285700000;
%     -0.942000000000000;
%     -1.82149419500000;
%     0.0952018367700000;
%     -0.135000000000000;
%     -1.63002300100000;
%     -0.0900683004500000;
%     -0.149000000000000;
%     -1.84522789900000]

%R = diag([R1 R2 R3 R4 Rc1 Rc2 Rc3 Rc4]);
%type = [type1; type2; type3; type4; typec1; typec2; typec3; typec4];
%indices = [indices1; indices2; indices3; indices4; indicesc1; indicesc2; indicesc3; indicesc4];

% Decentralized case: include boundary measurements for each area
% allbuses1 = [1; 2; 4; 5; 6]; %indices of x1
% allz1 = [z(1:6); z(20)]; 
% allR1 = diag([R1 Rc1]);
% alltype1 = [type1; typec1];
% allindices1 = [indices1; indicesc1];
% 
% allbuses2 = [2; 3; 4; 5; 7; 8; 9];
% allz2 = [z(7:10); z(21:25)];
% allR2 = diag([R2 Rc2]);
% alltype2 = [type2; typec2];
% allindices2 = [indices2; indicesc2];
% 
% allbuses3 = [6; 11; 12; 13; 14];
% allz3 = [z(11:16); z(26:28)];
% allR3 = diag([R3 Rc3]);
% alltype3 = [type3; typec3];
% allindices3 = [indices3; indicesc3];
% 
% allbuses4 = [9; 10; 11; 13; 14];
% allz4 = [z(17:19); z(29:31)];
% allR4 = diag([R4 Rc4]);
% alltype4 = [type4; typec4];
% allindices4 = [indices4; indicesc4];