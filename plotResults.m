%14 bus timing results
figure(1)
clf
parts14 = [1; 2; 4; 6; 8; 10; 12; 14];
time14 = [0.470706224; 0.431798795; 0.485293212; 0.532010059; 0.458557697; 0.522521412; 0.519225783; 0.64238525];

scatter(parts14,time14)
axis([0 14 0.4 0.67])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 14 Bus System')

figure(2)
parts57 = [1; 2; 4; 6; 8; 16; 24; 32; 44; 57];
time57 = [2.832382655; 1.617683358; 1.510744544; 1.513873129; 1.52448738; 1.638350415; 1.702256804; 1.796645567; 1.981769452; 2.144046639];

scatter(parts57,time57)
axis([0 57 1.4 3])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 57 Bus System')

figure(3)
clf
parts118 = [1; 2; 4; 8; 16; 32; 48; 64; 88; 118];
time118 = [10.11575984; 4.358883479; 3.515072237; 3.267506933; 3.367591737; 3.562605068; 3.778873233; 4.026537275; 4.376357774; 4.730648144];
scatter(parts118,time118)
axis([0 118 3 10.5])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 118 Bus System')

figure(4)
clf
parts300 = [1; 2; 4; 8; 16; 32; 62; 113; 174; 249; 300];
time300 = [72.65753643; 26.7090459; 14.58131138; 10.95713561; 9.548415066; 9.145823909; 9.334308516; 10.15220672; 19.94866286; 21.89567535; 23.46347436];
scatter(parts300,time300)
axis([0 300 8 75])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 300 Bus System')


