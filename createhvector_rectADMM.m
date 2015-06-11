function h = createhvector_rectADMM(e,f,G_a,B_a,type_a,indices_a,numbus,buses,buses_a,adjbuses,lines)
%% Inputs:
% This function creates the ideal h vector based on the rectangular
% state vector (e and f)
% Uses rectangular power flow, i.e. V_i = e_i + j*f_i = |V_i| ang (theta_i)

% e         partial vector of real V components (V cos theta)
% size(buses_a) x 1
% f         partial vector of imaginary V components (V sin theta)
% G_a       real part of the LOCAL Ybus matrix
% B_a       imaginary part of the LOCAL Ybus matrix
% type_a    each PARTITION's measurement type
% indices_a each PARTITION's measurement indices
% numbus    number of buses in overall system
% buses_a   list of buses in each PARTITION
% lines     list of lines in overall system 

h = zeros(size(type_a,1),1);
busIndex = (1:numbus).';
busIndex_a = (1:size(buses_a,1)).';

%% Determine type of measurement
for a = 1:size(type_a,1)
    % Real power injection measurements
    if strcmp(type_a(a),'p') == 1
        m_global = busIndex(buses == indices_a(a,1)); % map m to global bus index
        m = busIndex_a(buses_a==indices_a(a,1)); % m = bus at which P is injected
        temp = 0;
        temp2 = 0;
        temp3 = adjbuses(m_global,:); % get list of adjacent buses for bus m
        temp3 = temp3(temp3~=0); % remove padded zeros
        for b = 1:size(temp3,2) % go through each adjacent bus, including the injection bus itself
            n = busIndex_a(buses_a == temp3(b)); 
            temp = temp+(G_a(m,n)*e(n)-B_a(m,n)*f(n));
            temp2 = temp2+(G_a(m,n)*f(n)+B_a(m,n)*e(n));
        end
        h(a) = e(m)*temp+f(m)*temp2;
    % Reactive power injection measurements  
    elseif strcmp(type_a(a),'q') == 1
        m_global = busIndex(buses == indices_a(a,1)); % map m to global bus index
        m = busIndex_a(buses_a==indices_a(a,1)); % m = local bus index at which P is injected
        temp = 0;
        temp2 = 0;
        temp3 = adjbuses(m_global,:); % get list of adjacent buses for bus m
        temp3 = temp3(temp3~=0); % remove padded zeros
        for b = 1:size(temp3,2) % go through each adjacent bus, including the injection bus itself
            n = busIndex_a(buses_a == temp3(b));
            temp = temp+(-G_a(m,n)*f(n)-B_a(m,n)*e(n));
            temp2 = temp2+(G_a(m,n)*e(n)-B_a(m,n)*f(n));
        end
        h(a) = e(m)*temp + f(m)*temp2;
    % Real power flow measurements
    elseif strcmp(type_a(a),'pf') == 1
        m = busIndex_a(buses_a==indices_a(a,1));
        n = busIndex_a(buses_a==indices_a(a,2));
        ckt = indices_a(a,3);
        % Find the indices of the lines that have the same to and from
        % buses or vice versa
        paraLines1 = intersect(find(lines(:,1)==indices_a(a,1)),find(lines(:,2)==indices_a(a,2)));
        paraLines2 = intersect(find(lines(:,2)==indices_a(a,1)),find(lines(:,1)==indices_a(a,2)));
        paraLines = [paraLines1; paraLines2];
        if size(paraLines,1) == 1 %no multiple lines (or if the matrix is empty)
            % See Decentralized ADMM formulation.docx for more details
            h(a) = -G_a(m,n)*(e(m)^2+f(m)^2)+G_a(m,n)*(e(m)*e(n)+f(m)*f(n))+B_a(m,n)*(f(m)*e(n)-e(m)*f(n)); 
        % Look ahead by 2 measurements. If it's a multiple line, then use
        % current divider to calculate the PF based on their impedances.
        else %multiple lines
            lineNum = intersect(paraLines,find(lines(:,3)==ckt));
            Zeq = lines(lineNum,4)+1i*lines(lineNum,5);         
            g = real(1/Zeq);
            b = imag(1/Zeq);
            % See PowerWorld documentation for derivation
            gmn = -g;
            bmn = -b;
            gmm = g;
            h(a) = gmm*(e(m)^2+f(m)^2)+gmn*(e(m)*e(n)+f(m)*f(n))+bmn*(f(m)*e(n)-e(m)*f(n));
        end
    % Reactive power flow measurements 
    elseif strcmp(type_a(a),'qf') == 1
        m = busIndex_a(buses_a==indices_a(a,1));
        n = busIndex_a(buses_a==indices_a(a,2));
        ckt = indices_a(a,3);
        % Find the indices of the lines that have the same to and from
        % buses or vice versa
        paraLines1 = intersect(find(lines(:,1)==indices_a(a,1)),find(lines(:,2)==indices_a(a,2)));
        paraLines2 = intersect(find(lines(:,2)==indices_a(a,1)),find(lines(:,1)==indices_a(a,2)));
        paraLines = [paraLines1; paraLines2];
        lineNum = intersect(paraLines,find(lines(:,3)==ckt));
        if lines(lineNum,6) ~= 0
            bsi = lines(lineNum,6)/2;
        else bsi = 0;
        end
        if size(paraLines,1) == 1  %no multiple lines (or if the matrix is empty)
            h(a) = (B_a(m,n)-bsi)*(e(m)^2+f(m)^2)-B_a(m,n)*(e(m)*e(n)+f(m)*f(n))+G_a(m,n)*(f(m)*e(n)-e(m)*f(n));
        else %multiple lines
            Zeq = lines(lineNum,4)+1i*lines(lineNum,5);         
            g = real(1/Zeq);
            b = imag(1/Zeq);
            gmn = -g;
            bmn = -b;
            bmm = b+bsi;
            h(a) = -bmm*(e(m)^2+f(m)^2)-bmn*(e(m)*e(n)+f(m)*f(n))-gmn*(e(m)*f(n)-f(m)*e(n));
        end
    % Voltage magnitude measurements SQUARED (NOTE: SQUARED, so to get the
    % actual V magnitude, take the sqrt)
    elseif strcmp(type_a(a),'v') == 1
        m = busIndex_a(buses_a==indices_a(a,1));
        h(a) = e(m)^2+f(m)^2;
    % Angle measurement from PMUs
%     elseif strcmp(type_a(a),'th') == 1
%         m = busIndex(buses==indices_a(a,1));
%         h(a) = atan(f(m)/e(m));
    end
end