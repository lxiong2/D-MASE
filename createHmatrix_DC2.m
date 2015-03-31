function H = createHmatrix_DC2(theta,V,G,B,type,indices,numbus,buses,lines)

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
H = zeros(size(type,1),numbus);

%% Determine type of measurement
for a = 1:size(type,1)
    % Real power injection measurements [dPdth dPdV]
    if strcmp(type(a),'p') == 1
        numPmeas = numPmeas + 1;
        indPmeas = indices(a,:);
        [dPdth] = realPowerInjMeas_DC2(theta,V,G,B,numbus,buses,indPmeas);
        H(a,:) = dPdth;
    % Real power flow measurements [dPijdth dPijdV]
    elseif strcmp(type(a),'pf') == 1
        numPFmeas = numPFmeas + 1;
        indPFmeas = indices(a,:);
        [dPijdth] = realPowerFlowMeas_DC2(theta,V,numbus,buses,lines,indPFmeas);
        H(a,:) = dPijdth;
    elseif strcmp(type(a),'th') == 1
        numthmeas = numthmeas + 1;
        indthmeas = indices(a,:);
        [dthdth] = thMeas_DC(numbus,buses,indthmeas);
        H(a,:) = dthdth;
    end
end