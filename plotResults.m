%14 bus timing results
figure(1)
clf
parts14 = [1; 2; 4; 8; 14];
time14 = [0.470823937; 0.431153148; 0.483325861; 0.458873258; 0.642226071];
plot(parts14,time14)
axis([1 14 0.4 0.67])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 14 Bus System')

figure(2)
parts57 = [1; 2; 4; 8; 16; 32; 57];
time57 = [2.832382655; 1.617683358; 1.510744544; 1.52448738; 1.638350415; 1.796645567; 2.144046639];
plot(parts57,time57)
axis([1 57 1.4 3])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 57 Bus System')

figure(3)
clf
parts118 = [1; 2; 4; 8; 16; 32; 64; 118];
time118 = [10.11575984; 4.358883479; 3.515072237; 3.267506933; 3.367591737; 3.562605068; 4.026537275; 4.730648144];
plot(parts118,time118)
axis([1 118 3 10.5])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 118 Bus System')

figure(3)
clf
parts300 = [1; 2; 4; 8; 16; 32; 64; 118; 256; 300];
time300 = [];
plot(parts300,time300)
axis([1 300 3 10.5])
xlabel('Number of Partitions')
ylabel('Computational Time [s]')
title('IEEE 118 Bus System')


