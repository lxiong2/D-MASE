lines = [1 2 1 0.01 0.03 0;
         1 2 2 0.02 0.04 0];

Z1 = 0.01+1i*0.03;
Z2 = 0.02+1i*0.04;
Zeq = 0.006896551724137932+1i*0.017241379310344824;
B = 0;

Vk = 0.991167705170081;
dk = -0.016720281700806;
Vm = 1;
dm = 0;

%Yeq = 1/Zeq;
Yeq = 1/Z2;
g = real(Yeq);
b = imag(Yeq);

gkm = -g;
bkm = -b;
gkk = g;
gmm = g;
bkk = b+B/2;
bmm = b+B/2;

Pkm = Vk^2*gkk + Vk*Vm*(gkm*cos(dk-dm)+bkm*sin(dk-dm))
Qkm = -Vk^2*bkk + Vk*Vm*(gkm*sin(dk-dm)-bkm*cos(dk-dm))

%Pkm = gkk*(ek^2 + fk^2) + gkm*(ek*em + fk*fm) + bkm*(fk*em - ek*fm)
%Qkm = -bkk*(ek^2 + fk^2) - bkm*(fk*fm* + ek*em) - gkm*(ek*fm - fk*em) 