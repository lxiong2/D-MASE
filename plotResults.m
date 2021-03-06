%14 bus timing results
figure(1)
clf
parts14 = [1; 2; 4; 6; 8; 10; 12; 14];
time14 = [0.483086533; 0.373562816; 0.43406778; 0.440822613; 0.461936544; 0.465473531; 0.608701017; 0.651962658];
plot(parts14,time14,'g',parts14,time14,'go')
axis([0 14 0 1])
xlabel('Number of Partitions')
ylabel('SE Computation Time [s]')

% 57 bus timing results
figure(2)
parts57 = [1; 2; 4; 8; 16; 24; 32; 44; 57];
time57 = [2.97622159; 1.282744061; 1.18591082; 1.521267596; 1.638461477; 1.715340291; 1.847517911; 1.999654712; 2.19731091];
plot(parts57,time57,'k',parts57,time57,'ko')
axis([0 57 0 4])
xlabel('Number of Partitions')
ylabel('Computation Time [s]')

% 118 bus timing results
figure(3)
clf
parts118 = [1; 2; 4; 8; 16; 32; 48; 64; 88; 118];
time118 = [10.62816929; 4.467334545; 3.619083565; 3.35398465; 3.476577373; 3.663402134; 3.85453458; 4.135673796; 4.407024459; 4.866115286];
plot(parts118,time118,'r',parts118,time118,'ro')
axis([0 118 0 11])
xlabel('Number of Partitions')
ylabel('Computation Time [s]')

% 300 bus timing results
figure(4)
clf
parts300 = [1; 2; 4; 8; 16; 32; 62; 113; 174; 249; 300];
time300 = [75.8858499; 18.24720608; 12.15570846; 9.026753692; 7.77812539; 7.516000587; 7.671262458; 8.258176631; 9.147079335; 9.984232031; 10.70474644];
%time300 = [72.65753643; 26.7090459; 14.58131138; 10.95713561; 9.548415066; 9.145823909; 9.334308516; 10.15220672; 19.94866286; 21.89567535; 23.46347436];
plot(parts300,time300,'b',parts300,time300,'bo')
axis([0 300 0 80])
xlabel('Number of Partitions')
ylabel('Computation Time [s]')

% System comparison
speedup = [1.293186882 2.509650422 3.168818703 10.09657317];
figure(5)
clf
b = bar(speedup);
bar(1,speedup(1),'g');
hold on
bar(2,speedup(2),'k');
bar(3,speedup(3),'r');
bar(4,speedup(4),'b');
ylabel('Best Case Speedup Factor')
set(gca,'xtick',[1 2 3 4])
set(gca,'XtickLabel',{'IEEE14','IEEE57','IEEE118','IEEE300'})

% System comparison 2
minPart = [2 4 8 32];
sysSize = [14 57 118 300]
figure(6)
clf
plot(sysSize,minPart,'mo')
hold on
p = polyfit(sysSize,minPart,2)
x = 1:300;
plot(x,p(1).*x.^2+p(2).*x+p(3),'m--')
xlabel('System Size [# of Buses]')
ylabel('Fastest Number of Partitions')
legend('Actual Data','Projected Relationship')
