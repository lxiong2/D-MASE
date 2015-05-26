% IEEE 14-bus case
% see topology and measurement data from Korres 2011 
% "A distributed multiarea state estimation" 

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

% Based on the indices, automatically pull the "measurements" from
% PowerWorld and get the Ybus matrix
autoMeas           
           
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
