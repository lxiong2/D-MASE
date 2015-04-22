function h = createhvector_rect(e,f,G,B,type_a,indices_a,numbus,buses,buses_a,lines)
%% Inputs:
% This function creates the ideal h vector based on what the rectangular
% e and f components are
% Uses rectangular power flow, i.e. V_i = e_i + j*f_i = |V_i| ang (theta_i)

% e         partial vector of real V components (V cos theta)
% size(buses_a) x 1
% f         partial vector of imaginary V components (V sin theta)
% G         real part of Ybus matrix
% B         imaginary part of Ybus matrix
% type_a    each partition's measurement type
% indices_a each partition's measurement indices
% numbus    number of buses in overall system
% buses     list of buses in overall system
% buses_a   list of buses in each partition
% lines     list of lines in overall system 

e
f
type_a
indices_a
buses_a
numbus

h = zeros(size(type_a,1),1);
busIndex = (1:numbus).';

%% Determine type of measurement
for a = 1:size(type_a,1)
    a
    % Real power injection measurements
    if strcmp(type_a(a),'p') == 1
        m = busIndex(buses==indices_a(a,1)) % m = bus at which P is injected
        temp = 0;
        temp2 = 0;
        for n = 1:numbus
            temp = temp+(G(m,n)*e(n)-B(m,n)*f(n));
            temp2 = temp2+(G(m,n)*f(n)+B(m,n)*e(n));
        end
        h(a) = e(m)*temp+f(m)*temp2;
    % Reactive power injection measurements  
    elseif strcmp(type_a(a),'q') == 1
        m = busIndex(buses==indices_a(a,1)) % m = bus at which P is injected
        temp = 0;
        temp2 = 0;
        for n = 1:numbus
            temp = temp+(-G(m,n)*f(n)-B(m,n)*e(n));
            temp2 = temp2+(G(m,n)*e(n)-B(m,n)*f(n));
        end
        h(a) = e(m)*temp + f(m)*temp2;
    % Real power flow measurements
    elseif strcmp(type_a(a),'pf') == 1
        m = busIndex(buses==indices_a(a,1))
        n = busIndex(buses==indices_a(a,2))
        h(a) = -G(m,n)*(e(m)^2+f(m)^2)+G(m,n)*(e(m)*e(n)+f(m)*f(n))+B(m,n)*(f(m)*e(n)-e(m)*f(n));
    % Reactive power flow measurements 
    elseif strcmp(type_a(a),'qf') == 1
        m = busIndex(buses==indices_a(a,1))
        n = busIndex(buses==indices_a(a,2))
        for c = 1:size(lines,1)
            if sum(indices_a(a,1:3) == lines(c,1:3))==3
                lineNum = c;
            end
        end
        if lines(lineNum,6) ~= 0
            bsi = lines(lineNum,6)/2;
        else bsi = 0;
        end
        h(a) = (B(m,n)-bsi)*(e(m)^2+f(m)^2)-B(m,n)*(e(m)*e(n)+f(m)*f(n))+G(m,n)*(f(m)*e(n)-e(m)*f(n));
    % Voltage magnitude measurements SQUARED (NOTE: SQUARED, so to get the
    % actual V magnitude, take the sqrt)
    elseif strcmp(type_a(a),'v') == 1
        m = busIndex(buses==indices_a(a,1));
        h(a) = e(m)^2+f(m)^2;
    % Angle measurement from PMUs
    elseif strcmp(type_a(a),'th') == 1
        m = busIndex(buses==indices_a(a,1));
        h(a) = atan(f(m)/e(m));
    end
end