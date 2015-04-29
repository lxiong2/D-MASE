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

lineNum = size(lines,1);

% list of adjacent buses
adjbuses = [1 2 5 0 0 0;
            2 1 3 4 5 0;
            3 2 4 0 0 0;
            4 2 3 5 7 9;
            5 1 2 4 6 0;
            6 5 11 12 13 0;
            7 4 8 9 0 0;
            8 7 0 0 0 0;
            9 4 7 10 14 0;
            10 9 11 0 0 0; 
            11 6 10 0 0 0;
            12 6 13 0 0 0;
            13 6 12 14 0 0;
            14 9 13 0 0 0];

%% Measurement information

% PowerWorld AC; took out measurement P5-4
z = [% Area 1
    1.564407319;
    -0.203009359;
    0.759168813;
    -0.001555066;
    0.41338726;
    -0.038398609;
    2.323576212;
    -0.204564422;
    % Area 2
    -0.235697408;
    0.009685915;
    0.29247688;
    -0.101343842;
    4.93889E-07;
    -0.231382548;
    % Area 3
    0.064193753;
    0.015779898;
    0.076111237;
    0.0227493;
    0.172366211;
    0.06208869;
    0.014392072;
    0.00525268;
    -0.061;
    -0.016;
    % Area 4
    0.061481308;
    0.061776975;
    0.101258308;
    0.04877994;
    % Boundary 1
    -0.076;
    -0.016;
    % Boundary 2
    -0.630016998;
    0.102039486;
    0.165262115;
    -0.013436931;
    0.292476374;
    0.110919777;
    -0.94199997;
    0.024613438;
    % Boundary 3
    0.049650161;
    0.005242763;
    -0.135;
    -0.058;
    % Boundary 4
    -0.028744037;
    0.003177905;
    -0.149;
    -0.05;
    % Extra measurements
    0.729345746;
    0.035900361;
    0.424671655;
    -0.021273249;
     % V1^2
     % V5^2
     % V3^2
     % V8^2
     % V12^2
     % V13^2
     % V10^2
     % V9^2
    ];

%% PowerWorld AC case: angle and voltage measurements
% type = {% Area 1
%         'th'; 'v'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q';
%         % Area 2
%         'th'; 'v'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf';
%         % Area 3
%         'th'; 'v'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q';
%         % Area 4
%         'th'; 'v'; 'pf'; 'qf'; 'pf'; 'qf';
%         % Boundary 1
%         'p'; 'q';
%         % Boundary 2
%         'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q'; 'th'; 'v';
%         % Boundary 3
%         'pf'; 'qf'; 'p'; 'q'; 'th'; 'v';
%         % Boundary 4
%         'pf'; 'qf'; 'p'; 'q'; 'th'; 'v'};

%% PowerWorld AC case: no angle but voltage measurements
% ADMM converges for partitions 2, 3, and 4; however partition 1 doesn't converge
% Buses 1, 2, and 5 give extremely high errors (1e11)
% Buses 4 and 6 voltages give better errors (1e3)
% Partition 1 converges when you include V5 and V6

type = {% Area 1
        'v'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q';
        % Area 2
        'v'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf';
        % Area 3
        'v'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q';
        % Area 4
        'v'; 'pf'; 'qf'; 'pf'; 'qf';
        % Boundary 1
        'p'; 'q';
        % Boundary 2
        'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q'; 'v';
        % Boundary 3
        'pf'; 'qf'; 'p'; 'q'; 'v';
        % Boundary 4
        'pf'; 'qf'; 'p'; 'q'; 'v';
        % Extra measurements
        'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'
        };
    
indices = [% Area 1
%             1 0 0;
%             1 0 0;
            4 0 0;
            1 2 1;
            1 2 1;
            1 5 1;
            1 5 1;
            2 5 1;
            2 5 1;
            1 0 0;
            1 0 0;
            % Area 2
%             3 0 0;
            3 0 0;
            3 4 1;
            3 4 1;
            4 7 1;
            4 7 1;
            7 8 1;
            7 8 1;
            % Area 3
%             6 0 0;
            6 0 0;
            6 11 1;
            6 11 1;
            6 12 1;
            6 12 1;
            6 13 1;
            6 13 1;
            12 13 1;
            12 13 1;
            12 0 0;
            12 0 0;
            % Area 4
%             9 0 0;
            9 0 0;
            9 10 1;
            9 10 1;
            9 14 1;
            9 14 1;
            % Boundary 1
            5 0 0;
            5 0 0;
            % Boundary 2
            4 5 1;
            4 5 1;
            4 9 1;
            4 9 1;
            7 9 1;
            7 9 1;
            3 0 0;
            3 0 0;
%             3 0 0;
            3 0 0;
            % Boundary 3
            13 14 1;
            13 14 1;
            13 0 0;
            13 0 0;
%             6 0 0;
            6 0 0;
            % Boundary 4
            10 11 1;
            10 11 1;
            14 0 0;
            14 0 0;
%             9 0 0;
            9 0 0;
            % Extra measurements
            2 3 1;
            2 3 1;
            5 6 1;
            5 6 1;
            8 0 0;
            10 0 0
];

R = diag(0.01^2*ones(1,size(z,1)));

% Decentralized case: include boundary measurements for each area
% x1_k = [bus1 bus2 bus3' bus4' bus5 bus6']
% x2_k = [bus2' bus3 bus4 bus5' bus7 bus8 bus9']
% x3_k = [bus5' bus6 bus10' bus11 bus12 bus13 bus14']
% x4_k = [bus4' bus7' bus9 bus10 bus11' bus13' bus14]

allbuses1 = [1; 2; 4; 5; 6]; %indices of x1
allz1 = [z(1:9); z(33:34)]; %z(54:58)]; 
allR1 = diag(0.01^2*ones(1,size(allz1,1)));
alltype1 = [type(1:9); type(33:34)]; %type(54:58)]; 
allindices1 = [indices(1:9,:); indices(33:34,:)]; %indices(54:58,:)]; 

allbuses2 = [2; 3; 4; 5; 7; 8; 9];
allz2 = [z(10:16); z(35:43)]; %z(54:55); z(58)];
allR2 = diag(0.01^2*ones(1,size(allz2,1)));
alltype2 = [type(10:16); type(35:43)]; %type(54:55); type(58)];
allindices2 = [indices(10:16,:); indices(35:43,:)]; %indices(54:55,:); indices(58,:)];

allbuses3 = [6; 11; 12; 13; 14];
allz3 = [z(17:27); z(44:48)]; %z(56:57)];
allR3 = diag(0.01^2*ones(1,size(allz3,1)));
alltype3 = [type(17:27); type(44:48)]; %type(56:57)];
allindices3 = [indices(17:27,:); indices(44:48,:)]; %indices(56:57,:)];

allbuses4 = [9; 10; 11; 13; 14];
allz4 = [z(28:32); z(49:53)];
allR4 = diag(0.01^2*ones(1,size(allz4,1)));
alltype4 = [type(28:32); type(49:53)];
allindices4 = [indices(28:32,:); indices(49:53,:)];

%% PowerWorld AC measurements: no angle or V measurements - ADMM solution doesn't converge
% type = {% Area 1
%         'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q';
%         % Area 2
%         'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf';
%         % Area 3
%         'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q';
%         % Area 4
%         'pf'; 'qf'; 'pf'; 'qf';
%         % Boundary 1
%         'p'; 'q';
%         % Boundary 2
%         'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'p'; 'q';
%         % Boundary 3
%         'pf'; 'qf'; 'p'; 'q';
%         % Boundary 4
%         'pf'; 'qf'; 'p'; 'q'};

% indices = [% Area 1
% %             1 0 0;
% %             1 0 0;
%             1 2 1;
%             1 2 1;
%             1 5 1;
%             1 5 1;
%             2 5 1;
%             2 5 1;
%             1 0 0;
%             1 0 0;
%             % Area 2
% %             3 0 0;
% %             3 0 0;
%             3 4 1;
%             3 4 1;
%             4 7 1;
%             4 7 1;
%             7 8 1;
%             7 8 1;
%             % Area 3
% %             6 0 0;
% %             6 0 0;
%             6 11 1;
%             6 11 1;
%             6 12 1;
%             6 12 1;
%             6 13 1;
%             6 13 1;
%             12 13 1;
%             12 13 1;
%             12 0 0;
%             12 0 0;
%             % Area 4
% %             9 0 0;
% %             9 0 0;
%             9 10 1;
%             9 10 1;
%             9 14 1;
%             9 14 1;
%             % Boundary 1
%             5 0 0;
%             5 0 0;
%             % Boundary 2
%             4 5 1;
%             4 5 1;
%             4 9 1;
%             4 9 1;
%             7 9 1;
%             7 9 1;
%             3 0 0;
%             3 0 0;
% %             3 0 0;
% %             3 0 0;
%             % Boundary 3
%             13 14 1;
%             13 14 1;
%             13 0 0;
%             13 0 0;
% %             6 0 0;
% %             6 0 0;
%             % Boundary 4
%             10 11 1;
%             10 11 1;
%             14 0 0;
%             14 0 0;
% %             9 0 0;
% %             9 0 0
% ];
% 
% R = diag(0.01^2*ones(1,size(z,1)));
% 
% % Decentralized case: include boundary measurements for each area
% allbuses1 = [1; 2; 4; 5; 6]; %indices of x1
% allz1 = [z(1:8); z(29:30)]; 
% allR1 = diag(0.01^2*ones(1,size(allz1,1)));
% alltype1 = [type(1:8); type(29:30)]; 
% allindices1 = [indices(1:8,:); indices(29:30,:)]; 
% 
% allbuses2 = [2; 3; 4; 5; 7; 8; 9];
% allz2 = [z(9:14); z(31:38)];
% allR2 = diag(0.01^2*ones(1,size(allz2,1)));
% alltype2 = [type(9:14); type(31:38)];
% allindices2 = [indices(9:14,:); indices(31:38,:)];
% 
% allbuses3 = [6; 11; 12; 13; 14];
% allz3 = [z(15:24); z(39:42)];
% allR3 = diag(0.01^2*ones(1,size(allz3,1)));
% alltype3 = [type(15:24); type(39:42)];
% allindices3 = [indices(15:24,:); indices(39:42,:)];
% 
% allbuses4 = [9; 10; 11; 13; 14];
% allz4 = [z(25:28); z(43:46)];
% allR4 = diag(0.01^2*ones(1,size(allz4,1)));
% alltype4 = [type(25:28); type(43:46)];
% allindices4 = [indices(25:28,:); indices(43:46,:)];

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
            