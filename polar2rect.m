numbus = 14;
k = 1;

x = [0.0000000000000000;
    -0.0908267141386695;
    -0.1089143426654649;
    -0.1485175407205641;
    -0.1323447464566713;
    -0.2280900983537723;
    -0.2065660539581082;
    -0.2065659663111520;
    -0.2367788498625365;
    -0.2404926918120009;
    -0.2367712414561624;
    -0.2432688116004266;
    -0.2446088592878369;
    -0.2582798206552778;
    1.0599999427795410;
    1.0449999309531599;
    1.0357887047348926;
    1.0319210818052977;
    1.0347186607351298;
    1.0450431051688001;
    1.0530933573977659;
    1.0900000454534755;
    1.0425722829553701;
    1.0355433120664188;
    1.0368204190699797;
    1.0307012882817059;
    1.0267663401966221;
    1.0173917310026952];   

%% Convert polar state variables to rectangular form
newth = x(1:numbus,k);
newV = x(numbus+1:(2*numbus),k);
newe = zeros(numbus,1);
newf = zeros(numbus,1);
for a = 1:numbus
    newe(a) = newV(a)*cos(newth(a));
    newf(a) = newV(a)*sin(newth(a));
end
newe
newf

%% Convert rectangular state variables to polar form
% newe = x(1:numbus,k);
% newf = [0; x(numbus+1:(2*numbus-1),k)];
% newth = zeros(numbus,1);
% newV = zeros(numbus,1);
% for a = 1:numbus
%     newV(a) = sqrt(newe(a)^2+newf(a)^2);
%     newth(a) = atan(newf(a)/newe(a));
% end
% newth
% newV
