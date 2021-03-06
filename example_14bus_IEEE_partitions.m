% IEEE 14-bus case
% see topology and measurement data from Korres 2011 
% "A distributed multiarea state estimation" 

simauto = actxserver('pwrworld.SimulatorAuto');

% Automatically create fake measurements using PowerWorld
% Preemptively convert to per unit

% NOTE: Check case file path before running
simauto.OpenCase('C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb')

% Automatically save Ybus
simauto.RunScriptCommand('SaveYbusInMatlabFormat("C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\YBus.m",NO)');

busIndex = (1:14).';
buses = (1:14).';
numbus = size(buses,1);
globalSlack = 1;
globalSlackArea = 1;
globalSlackIndex = busIndex(buses == globalSlack);

%% Line Information
% line data for full AC system
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

% AC line data
lines1 = [1 2 1 0.01938 0.05917 0.0528;
          1 5 1 0.05403 0.22304 0.0492;
          2 5 1 0.05695 0.17388 0.0346;
          % Tie lines
          2 3 1 0.04699 0.19797 0.0438;
          2 4 1 0.05811 0.17632 0.034;
          4 5 1 0.01335 0.04211 0;
          5 6 1 0 0.25202 0
          ];
     
lines2 = [3 4 1 0.06701 0.17103 0.0128;
          4 7 1 0 0.20912 0;
          7 8 1 0 0.17615 0;
          % Tie lines
          2 3 1 0.04699 0.19797 0.0438;
          4 5 1 0.01335 0.04211 0;
          4 9 1 0 0.55618 0;
          7 9 1 0 0.11001 0];
      
lines3 = [6 11 1 0.09498 0.1989 0;
          6 12 1 0.12291 0.25581 0;
          6 13 1 0.06615 0.13027 0;
          12 13 1 0.22092 0.19988 0;
          % Tie lines
          5 6 1 0 0.25202 0;
          10 11 1 0.08205 0.19207 0;
          13 14 1 0.17093 0.34802 0];
         
lines4 = [9 10 1 0.03181 0.0845 0;
          9 14 1 0.12711 0.27038 0;
          % Tie lines
          4 9 1 0 0.55618 0;
          7 9 1 0 0.11001 0;
          10 11 1 0.08205 0.19207 0;
          13 14 1 0.17093 0.34802 0];

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

%% Full measurement information from PowerWorld AC power flow results

% Partition 1
% x1_k = [bus1 bus2 bus3' bus4' bus5 bus6']
allbuses1 = [1; 2; 3; 4; 5; 6];
numbus1 = size(allbuses1,1);
% allz1 = [1.564407319;
%         -0.203009359;
%         0.759168813;
%         -0.001555066;
%         0.41338726;
%         -0.038398609;
%         1.059999943^2;
%         1.044999958^2;
%         1.028092515^2;
%         2.323576212;
%         -0.204564422;
%         0.183000016;
%         0.221948747;
%         -0.076;
%         -0.016;
%         % Boundary measurements
%         0.729345746;
%         0.035900361;
%         0.635205895;
%         -0.085672111;
%         0.424671655;
%         -0.021273249
%         ];
alltype1 = {'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v';
            'p'; 'q'; 'p'; 'q'; 'p'; 'q';
            'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'
            };
allR1 = diag(0.01^2*ones(1,size(alltype1,1)));        
allindices1 = [1 2 1;
               1 2 1;
               1 5 1;
               1 5 1;
               2 5 1;
               2 5 1;
               1 0 0;
               2 0 0;
               5 0 0;
               1 0 0;
               1 0 0;
               2 0 0;
               2 0 0;
               5 0 0;
               5 0 0;
               % Boundary measurements
               2 3 1;
               2 3 1;
               5 4 1;
               5 4 1;
               5 6 1;
               5 6 1
               ];

%% Partition 2
% x2_k = [bus2' bus3 bus4 bus5' bus7 bus8 bus9']
allbuses2 = [2; 3; 4; 5; 7; 8; 9];
numbus2 = size(allbuses2,1);
% allz2 = [-0.235697408;
%         0.009685915;
%         0.29247688;
%         -0.101343842;
%         4.93889E-07;
%         -0.231382548;
%         1.009999997^2;
%         1.023712865^2;
%         1.046122452^2;
%         1.085083507^2;
%         -0.94199997;
%         0.024613438;
%         -0.47799999;
%         0.039;
%         0;
%         0;
%         0;
%         0.239999995;
%         -0.706302103;
%         0.014927527;
%         -0.630016998;
%         0.102039486;
%         0.292476374;
%         0.110919777];
alltype2 = {'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v'; 'v';
            'p'; 'q'; 'p'; 'q'; 'p'; 'q'; 'p'; 'q';
            'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'};
allR2 = diag(0.01^2*ones(1,size(alltype2,1)));        
allindices2 = [3 4 1;
               3 4 1;
               4 7 1;
               4 7 1;
               7 8 1;
               7 8 1;
               3 0 0;
               4 0 0;
               7 0 0;
               8 0 0;
               3 0 0;
               3 0 0;
               4 0 0;
               4 0 0;
               7 0 0;
               7 0 0;
               8 0 0;
               8 0 0;
               3 2 1;
               3 2 1;
               4 5 1;
               4 5 1;
               7 9 1;
               7 9 1];

%% Partition 3
% x3_k = [bus5' bus6 bus10' bus11 bus12 bus13 bus14']
allbuses3 = [5; 6; 10; 11; 12; 13; 14];
numbus3 = size(allbuses3,1);
% allz3 = [0.064193753;
%         0.015779898;
%         0.076111237;
%         0.0227493;
%         0.172366211;
%         0.06208869;
%         0.014392072;
%         0.00525268;
%         1.038537902^2;
%         1.029702054^2;
%         1.024052523^2;
%         1.019923836^2;
%         -0.112;
%         0.164999995;
%         -0.035;
%         -0.018;
%         -0.061;
%         -0.016;
%         -0.135;
%         -0.058;
%         % Boundary measurements
%         -0.424671638;
%         0.064382015;
%         0.028808971;
%         -0.0030259;
%         0.049650161;
%         0.005242763];
alltype3 = {'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v'; 'v';
            'p'; 'q'; 'p'; 'q'; 'p'; 'q'; 'p'; 'q';
            'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'};
allR3 = diag(0.01^2*ones(1,size(alltype3,1)));        
allindices3 = [6 11 1;
               6 11 1;
               6 12 1;
               6 12 1;
               6 13 1; 
               6 13 1;
               12 13 1;
               12 13 1;
               6 0 0;
               11 0 0;
               12 0 0;
               13 0 0;
               6 0 0;
               6 0 0;
               11 0 0;
               11 0 0;
               12 0 0;
               12 0 0;
               13 0 0;
               13 0 0;
               % Boundary measurements
               6 5 1;
               6 5 1;
               11 10 1;
               11 10 1;
               13 14 1;
               13 14 1];

%% Partition 4
% x4_k = [bus4' bus7' bus9 bus10 bus11' bus13' bus14]
allbuses4 = [4; 7; 9; 10; 11; 13; 14];
numbus4 = size(allbuses4,1);
% allz4 = [0.061481308;
%         0.061776975;
%         0.101258308;
%         0.04877994;
%         1.034915258^2;
%         1.027986216^2;
%         1.009941724^2;
%         -0.29499999;
%         -0.16599999;
%         -0.09;
%         -0.058;
%         -0.149;
%         -0.05;
%         % Boundary measurements
%         -0.160798157;
%         0.01732381;
%         -0.292476374;
%         -0.110919777;
%         -0.028744037;
%         0.003177905;
%         -0.049650161;
%         -0.005242763];  
alltype4 = {'pf'; 'qf'; 'pf'; 'qf'; 'v'; 'v'; 'v';
            'p'; 'q'; 'p'; 'q'; 'p'; 'q';
            'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'; 'pf'; 'qf'};
allR4 = diag(0.01^2*ones(1,size(alltype4,1)));         
allindices4 = [9 10 1;
               9 10 1;
               9 14 1;
               9 14 1;
               9 0 0;
               10 0 0;
               14 0 0;
               9 0 0;
               9 0 0;
               10 0 0;
               10 0 0;
               14 0 0;
               14 0 0;
               % Boundary measurements
               9 4 1;
               9 4 1;
               9 7 1;
               9 7 1;
               10 11 1;
               10 11 1;
               14 13 1;
               14 13 1];

% Automatically pull "measurements" from PowerWorld case
autoMeas
simauto.CloseCase();

% Slack buses (one for each partition)
slack1 = 1;
slack2 = 3;
slack3 = 6;
slack4 = 9;
busIndex1 = (1:numbus1).';
busIndex2 = (1:numbus2).';
busIndex3 = (1:numbus3).';
busIndex4 = (1:numbus4).';
slackIndex1 = busIndex1(allbuses1==slack1);
slackIndex2 = busIndex2(allbuses2==slack2);
slackIndex3 = busIndex3(allbuses3==slack3);
slackIndex4 = busIndex4(allbuses4==slack4);
           
%% Aggregated measurements
z = [allz1; allz2; allz3; allz4];
R = diag(0.01^2*ones(1,size(z,1)));
type = [alltype1; alltype2; alltype3; alltype4];
indices = [allindices1; allindices2; allindices3; allindices4];
