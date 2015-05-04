numbus = 14;

V14 = [1.059999942779541;
       1.044999957975790;
       1.009999997308001;
       1.023712864563319;
       1.028092514790582;
       1.038537901983267;
       1.046122452014562;
       1.085083507155382;
       1.034915257722165;
       1.027986215563745;
       1.029702053504086;
       1.024052523011952;
       1.019923836318137;
       1.009941724464959]
   
th14 = [0.000000000000000;
        -0.086707362007296;
        -0.221252722177700;
        -0.181203460483033;
        -0.154698697268199;
        -0.255105633878135;
        -0.238346440923459;
        -0.238346537949173;
        -0.268069905913210;
        -0.271106013451292;
        -0.265644004346752;
        -0.270784345341965;
        -0.272427561300289;
        -0.288333174463255]
    
e = zeros(numbus,1);
f = zeros(numbus,1);
for a = 1:numbus
    e(a) = V14(a)*cos(th14(a));
    f(a) = V14(a)*sin(th14(a));
end
    
    