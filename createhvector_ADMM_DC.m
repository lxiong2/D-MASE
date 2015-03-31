function h = createhvector_ADMM_DC(theta,V,G,B,type,allindices_a,numbus,buses,allbuses_a,adjbuses,lines)

% used small angle approximations

h = zeros(size(type,1),1);
busIndex = (1:numbus).';
numbus_a = size(allbuses_a,1);
busIndex_a = (1:numbus_a).';
% WARNING: assumed that gsi = 0
gsi = 0;

%% Determine type of measurement
for a = 1:size(type,1)
    % Real power injection measurements
    if strcmp(type(a),'p') == 1
        m = busIndex(buses==allindices_a(a,1)); % convert area indices into global bus index (ex. bus 103 -> bus 3)
        m_a = busIndex_a(allbuses_a==allindices_a(a,1)); % convert area indices into state vector index for each partition
        temp = 0;
        for b = 1:size(adjbuses(1,:),2)
            if adjbuses(m,b) ~= 0
                n = adjbuses(m,b);
                n_a = busIndex_a(allbuses_a==adjbuses(m,b));
                temp = temp + V(n_a)*(G(m,n)*(1-(theta(m_a)-theta(n_a))^2/2)+...
                    B(m,n)*(theta(m_a)-theta(n_a)));
            end
        end
        h(a) = V(m_a)*temp;
    % Real power flow measurements
    elseif strcmp(type(a),'pf') == 1
        m = busIndex_a(allbuses_a==allindices_a(a,1));
        n = busIndex_a(allbuses_a==allindices_a(a,2));
        for c = 1:size(lines,1)
            if sum(allindices_a(a,1:3) == lines(c,1:3))==3
                lineNum = c;
            end
        end
        ztemp = 1/(lines(lineNum,4)+1i*lines(lineNum,5));
        gij = real(ztemp);
        bij = imag(ztemp);
        h(a) = V(m).^2*(gsi+gij)-V(m)*V(n)*...
            (gij*(1-(theta(m)-theta(n))^2/2)+bij*(theta(m)-theta(n)));
    % Angle measurement from PMUs
    elseif strcmp(type(a),'th') == 1
        m_a = busIndex_a(allbuses_a==allindices_a(a,1));
        h(a) = theta(m_a);
    end
end