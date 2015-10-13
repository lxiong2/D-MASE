clc
clear all
close all
format long

maxreps = 2;

centralSEt = zeros(1,maxreps);
distSEt = zeros(1,maxreps);

for numreps = 1:maxreps
    clearvars -except numreps centralSEt distSEt
    option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
    casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb';
    YBus14
    
    centralSE
    centralSEt(numreps) = totalt;
    
    clearvars -except numreps centralSEt distSEt
    option = 3; %how to get partitions: 1 - manual, 2 - from PW, 3 - from METIS
    casepath = 'C:\Users\lxiong7.AD\Documents\GitHub\D-MASE\IEEE 14 bus.pwb';
    filename = 'graph14_2parts.txt'; % only matters if option = 3
    numParts = 2; % should match filename if option = 3
    casename = 14;
    YBus14
    DMASE_ADMM
    distSEt(numreps) = totalt;
end