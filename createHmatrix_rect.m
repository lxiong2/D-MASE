function H = createHmatrix_rect(e,f,G,B,type,indices,numbus,buses,lines)

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
        [dPde, dPdf] = realPowerInjMeas_rect(e,f,G,B,numbus,buses,indPmeas);
        H(a,:) = [dPde dPdf];
    % Reactive power injection measurements [dQdth dQdV]   
    elseif strcmp(type(a),'q') == 1
        numQmeas = numQmeas + 1;
        indQmeas = indices(a,:);
        [dQde, dQdf] = reactivePowerInjMeas_rect(e,f,G,B,numbus,buses,indQmeas);
        H(a,:) = [dQde dQdf];
    % Real power flow measurements [dPijdth dPijdV]
    elseif strcmp(type(a),'pf') == 1
        numPFmeas = numPFmeas + 1;
        indPFmeas = indices(a,:);
        [dPijde, dPijdf] = realPowerFlowMeas_rect(e,f,G,B,numbus,buses,lines,indPFmeas);
        H(a,:) = [dPijde dPijdf];
    % Reactive power flow measurements [dQijdth dQijdV]   
    elseif strcmp(type(a),'qf') == 1
        numQFmeas = numQFmeas + 1;
        indQFmeas = indices(a,:);
        [dQijde, dQijdf] = reactivePowerFlowMeas_rect(e,f,G,B,numbus,buses,lines,indQFmeas);
        H(a,:) = [dQijde dQijdf];
    % Voltage magnitude measurements    
    elseif strcmp(type(a),'v') == 1
        numVmeas = numVmeas + 1;
        indVmeas = indices(a,:);
        [dV2de, dV2df] = vMeas_rect(e,f,numbus,buses,indVmeas);
        H(a,:) = [dV2de dV2df];
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
        [dth2de, dth2df] = thMeas_rect(e,f,numbus,buses,indthmeas);
        H(a,:) = [dth2de dth2df];
    end
end