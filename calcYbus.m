% Author: Leilei Xiong
% Date Created: August 29, 2011
% Date Revised: March 26, 2013

function [Ybus] = calcYbus(buses, FromBus, ToBus, R, X, B, status)
% calcYbus:
% Computes the bus admittance matrix of an n-bus power system
%
% Inputs:
% ============================================================
% buses:    vector of bus numbers               (vector)
% FromBus:  Connection from Bus i               (column vector)
% ToBus:    Connection to Bus j                 (column vector)
% R:        line resistance in per unit         (column vector)
% X:        line reactance in per unit          (column vector)
% B:        total line charging in per unit     (column vector)
% status:   status of each line
%           'Open' or 'Closed'                  (column vector)
% ============================================================
%
% Outputs:
% ============================================================
% Ybus:  bus admittance matrix                  (n x n matrix)
% ============================================================
%
% For a system with n buses:
% - Ybus should be a n x n symmetric matrix
% - Off-diagonal terms are equal to the negative of the sum of the
% admittances joining the two buses
% - Diagonal terms are equal to the sum of the admittances of all devices
% and line charging incident to bus i 

numbuses = size(buses,1);
numlines = length(FromBus);
Ybus = zeros(numbuses,numbuses);
offDiagY = -1./(R+1i*X);

busIndex = (1:numbuses).';

% contributions = zeros(numlines,numbuses);
 
for a = 1:numlines
    if strcmp(status(a),'Closed')
        %fromIndex = find(buses(:,1) == FromBus(a,1));
        %toIndex = find(buses(:,1) == ToBus(a,1));
        fromIndex = busIndex(buses(:,1) == FromBus(a,1));
        toIndex = busIndex(buses(:,1) == ToBus(a,1));
        Ybus(fromIndex,toIndex) = Ybus(fromIndex,toIndex) + offDiagY(a); %Calculate off-diagonal values
        Ybus(toIndex,fromIndex) = Ybus(fromIndex,toIndex); %Exploit symmetry
%         contributions(a,fromIndex) = contributions(a,fromIndex) + offDiagY(a);
%         contributions(a,toIndex) = contributions(a,toIndex) + offDiagY(a);
    %% POSSIBLE ERROR HERE
        Ybus(fromIndex,fromIndex) = -offDiagY(a) + 1i*B(a)/2 + ...
        Ybus(fromIndex,fromIndex); %Accumulates off-diagonal values and then
        %adds in total line charging contribution to the "from bus" 
        Ybus(toIndex,toIndex) = -offDiagY(a) + 1i*B(a)/2 + ...
        Ybus(toIndex,toIndex); %Accumulates off-diagonal values and then 
        %adds in total line charging contribution to the "to bus"
    end
end


