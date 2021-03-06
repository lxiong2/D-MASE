function H = createHmatrix(theta,V,G,B,type,indices,numbus,buses,lines)

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
H = zeros(size(type,1),numbus*2);

%% Determine type of measurement
for a = 1:size(type,1)
    % Real power injection measurements [dPdth dPdV]
    if strcmp(type(a),'p') == 1
        numPmeas = numPmeas + 1;
        indPmeas = indices(a,:);
        [dPdth dPdV] = realPowerInjMeas(theta,V,G,B,numbus,buses,indPmeas);
        H(a,:) = [dPdth dPdV];
    % Reactive power injection measurements [dQdth dQdV]   
    elseif strcmp(type(a),'q') == 1
        numQmeas = numQmeas + 1;
        indQmeas = indices(a,:);
        [dQdth dQdV] = reactivePowerInjMeas(theta,V,G,B,numbus,buses,indQmeas);
        H(a,:) = [dQdth dQdV];
    % Real power flow measurements [dPijdth dPijdV]
    elseif strcmp(type(a),'pf') == 1
        numPFmeas = numPFmeas + 1;
        indPFmeas = indices(a,:);
        [dPijdth dPijdV] = realPowerFlowMeas(theta,V,numbus,buses,lines,indPFmeas);
        H(a,:) = [dPijdth dPijdV];
    % Reactive power flow measurements [dQijdth dQijdV]   
    elseif strcmp(type(a),'qf') == 1
        numQFmeas = numQFmeas + 1;
        indQFmeas = indices(a,:);
        [dQijdth dQijdV] = reactivePowerFlowMeas(theta,V,numbus,buses,lines,indQFmeas);
        H(a,:) = [dQijdth dQijdV];
    % Voltage magnitude measurements    
    elseif strcmp(type(a),'v') == 1
        numVmeas = numVmeas + 1;
        indVmeas = indices(a,:);
        [dVdth dVdV] = vMeas(numbus,buses,indVmeas);
        H(a,:) = [dVdth dVdV];
%     % Current magnitude measurements
    %FIX: NOT DEBUGGED OR TESTED
%     elseif strcmp(type(a),'i') == 1
%         numImeas = numImeas + 1;
%         indImeas = indices(a,:);  
%         [dIijdth dIijdV] = iMeas(theta,V,I,numbus,buses,lines,numImeas,indImeas);
%         H(a,:) = [dIijdth dIijdV];
    elseif strcmp(type(a),'th') == 1
        numthmeas = numthmeas + 1;
        indthmeas = indices(a,:);
        [dthdth dthdV] = thMeas(numbus,buses,indthmeas);
        H(a,:) = [dthdth dthdV];
    end
end