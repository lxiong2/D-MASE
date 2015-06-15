function h = createhvector_rect(e,f,G,B,type,indices,numbus,buses,lines)
% Rectangular power flow
% V_i = e_i + j*f_i = |V_i| ang (theta_i)
% Includes what to do for parallel lines

h = zeros(size(type,1),1);
busIndex = (1:numbus).';
% Assume gsi = 0

%% Determine type of measurement
for a = 1:size(type,1)
    % Real power injection measurements
    if strcmp(type(a),'p') == 1
        m = busIndex(buses==indices(a,1)); % m = bus at which P is injected
        temp = 0;
        temp2 = 0;
        for n = 1:numbus
            n;
            temp = temp+(G(m,n)*e(n)-B(m,n)*f(n));
            temp2 = temp2+(G(m,n)*f(n)+B(m,n)*e(n));
        end
        h(a) = e(m)*temp+f(m)*temp2;
    % Reactive power injection measurements  
    elseif strcmp(type(a),'q') == 1
        m = busIndex(buses==indices(a,1)); % m = bus at which P is injected
        temp = 0;
        temp2 = 0;
        for n = 1:numbus
            temp = temp+(-G(m,n)*f(n)-B(m,n)*e(n));
            temp2 = temp2+(G(m,n)*e(n)-B(m,n)*f(n));
        end
        h(a) = e(m)*temp + f(m)*temp2;
    % Real power flow measurements
    elseif strcmp(type(a),'pf') == 1
        m = busIndex(buses==indices(a,1));
        n = busIndex(buses==indices(a,2));
        ckt = indices(a,3);
        % Find the indices of the lines that have the same to and from
        % buses or vice versa
        paraLines1 = intersect(find(lines(:,1)==indices(a,1)),find(lines(:,2)==indices(a,2)));
        paraLines2 = intersect(find(lines(:,2)==indices(a,1)),find(lines(:,1)==indices(a,2)));
        paraLines = [paraLines1; paraLines2];
        if size(paraLines,1) == 1 %no multiple lines (or if the matrix is empty)     
            h(a) = -G(m,n)*(e(m)^2+f(m)^2)+G(m,n)*(e(m)*e(n)+f(m)*f(n))+B(m,n)*(f(m)*e(n)-e(m)*f(n));
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
    elseif strcmp(type(a),'qf') == 1
        m = busIndex(buses==indices(a,1));
        n = busIndex(buses==indices(a,2));
        ckt = indices(a,3);
        % Find the indices of the lines that have the same to and from
        % buses or vice versa
        paraLines1 = intersect(find(lines(:,1)==indices(a,1)),find(lines(:,2)==indices(a,2)));
        paraLines2 = intersect(find(lines(:,2)==indices(a,1)),find(lines(:,1)==indices(a,2)));
        paraLines = [paraLines1; paraLines2];
        lineNum = intersect(paraLines,find(lines(:,3)==ckt));
        if lines(lineNum,6) ~= 0
            bsi = lines(lineNum,6)/2;
        else bsi = 0;
        end
        if size(paraLines,1) == 1  %no multiple lines (or if the matrix is empty)
            h(a) = (B(m,n)-bsi)*(e(m)^2+f(m)^2)-B(m,n)*(e(m)*e(n)+f(m)*f(n))+G(m,n)*(f(m)*e(n)-e(m)*f(n));
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
    elseif strcmp(type(a),'v') == 1
        m = busIndex(buses==indices(a,1));
        h(a) = e(m)^2+f(m)^2;
    % Current magnitude measurements
%     elseif strcmp(type(a),'i') == 1
%     % WARNING: NOT DEBUGGED OR TESTED
%     % ASSUMPTION: ignore the shunt admittance (gsi+1i*bsi)
%         m = busIndex(buses==indices(a,1));
%         n = busIndex(buses==indices(a,2));
%         for c = 1:size(lines,1)
%             if indices(:,1:3) == lines(c,1:3)
%                 lineNum = c;
%             end
%         end
%         ztemp = 1/(lines(lineNum,4)+1i*lines(lineNum,5));
%         gij = real(ztemp);
%         bij = imag(ztemp);
%         h(a) = sqrt((gij^2+bij^2)*(V(m).^2+V(n)^2-...
%             2*V(m)*V(n)*cos(theta(m)-theta(n))));
    % Angle measurement from PMUs
%     elseif strcmp(type(a),'th') == 1
%         m = busIndex(buses==indices(a,1));
%         h(a) = theta(m);
    end
end