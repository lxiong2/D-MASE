function h = createhvector(theta,V,G,B,type,indices,numbus,buses,lines)

h = zeros(size(type,1),1);
busIndex = (1:numbus).';
% WARNING: assumed that gsi = 0
gsi = 0;

%% Determine type of measurement
for a = 1:size(type,1)
    % Real power injection measurements
    if strcmp(type(a),'p') == 1
        m = busIndex(buses==indices(a,1)); % m = bus at which P is injected
        temp = 0;
        for n = 1:numbus
            temp = temp + V(n)*(G(m,n)*cos(theta(m)-theta(n))+...
                B(m,n)*sin(theta(m)-theta(n)));
        end
        h(a) = V(m)*temp;
    % Reactive power injection measurements  
    elseif strcmp(type(a),'q') == 1
        m = busIndex(buses==indices(a,1)); % m = bus at which P is injected
        temp = 0;
        for n = 1:numbus
            temp = temp + V(n)*(G(m,n)*sin(theta(m)-theta(n))-...
                B(m,n)*cos(theta(m)-theta(n)));
        end
        h(a) = V(m)*temp;
    % Real power flow measurements
    elseif strcmp(type(a),'pf') == 1
        m = busIndex(buses==indices(a,1));
        n = busIndex(buses==indices(a,2));
        for c = 1:size(lines,1)
            if sum(indices(a,1:3) == lines(c,1:3))==3
                lineNum = c;
            end
        end
        ztemp = 1/(lines(lineNum,4)+1i*lines(lineNum,5));
        gij = real(ztemp);
        bij = imag(ztemp);
        h(a) = V(m).^2*(gsi+gij)-V(m)*V(n)*...
            (gij*cos(theta(m)-theta(n))+bij*sin(theta(m)-theta(n)));
    % Reactive power flow measurements 
    elseif strcmp(type(a),'qf') == 1
        m = busIndex(buses==indices(a,1));
        n = busIndex(buses==indices(a,2));
        for c = 1:size(lines,1)
            if sum(indices(a,1:3) == lines(c,1:3))==3
                lineNum = c;
            end
        end
        ztemp = 1/(lines(lineNum,4)+1i*lines(lineNum,5));
        gij = real(ztemp);
        bij = imag(ztemp);
        if lines(lineNum,6) ~= 0
            bsi = lines(lineNum,6)/2;
        else bsi = 0;
        end
        h(a) = -V(m).^2*(bsi+bij)-V(m)*V(n)*...
            (gij*sin(theta(m)-theta(n))-bij*cos(theta(m)-theta(n)));
    % Voltage magnitude measurements
    elseif strcmp(type(a),'v') == 1
        m = busIndex(buses==indices(a,1));
        h(a) = V(m);
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
    elseif strcmp(type(a),'th') == 1
        m = busIndex(buses==indices(a,1));
        h(a) = theta(m);
    end
end