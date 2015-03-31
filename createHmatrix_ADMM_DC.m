function H = createHmatrix_ADMM_DC(theta,V,G,B,type,indices,numbus,buses,allbuses_a,adjbuses,lines)

%% Initialize
% Real power injection
numPmeas = 0; 
% Reactive power injection
numQmeas = 0;
% Real power flow
numPFmeas = 0;
% Reactive power flow
numQFmeas = 0;
% Voltage
numVmeas = 0;
% Current
numImeas = 0;
% Angle
numthmeas = 0;
% measurement Jacobian H
numbus_a = size(allbuses_a,1);
H = zeros(size(type,1),numbus_a);

%% Determine type of measurement
for a = 1:size(type,1)
    % Real power injection measurements [dPdth dPdV]
    if strcmp(type(a),'p') == 1
        numPmeas = numPmeas + 1;
        indPmeas = indices(a,:);
        [dPdth] = realPowerInjMeas_ADMM_DC(theta,V,G,B,numbus,buses,allbuses_a,adjbuses,indPmeas);
        H(a,:) = dPdth;
    % Real power flow measurements [dPijdth dPijdV]
    elseif strcmp(type(a),'pf') == 1
        numPFmeas = numPFmeas + 1;
        indPFmeas = indices(a,:);
        [dPijdth] = realPowerFlowMeas_ADMM_DC(theta,V,numbus,buses,allbuses_a,lines,indPFmeas);
        H(a,:) = dPijdth;
    elseif strcmp(type(a),'th') == 1
        numthmeas = numthmeas + 1;
        indthmeas = indices(a,:);
        [dthdth] = thMeas_ADMM_DC(numbus,buses,allbuses_a,indthmeas);
        H(a,:) = dthdth;
    end
end