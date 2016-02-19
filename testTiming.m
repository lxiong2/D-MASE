%% Time bus index vs find
% numElements = 10000;
% buses = (1:numElements).';
% findBusNum = 10000;
% 
% tic
% busIndex = (1:numElements).';
% m1 = busIndex(buses==findBusNum);
% toc
% 
% tic
% m2 = find(buses==findBusNum);
% toc

% % Conclusion: find is actually faster than bus index

%% For loop vs vectorized
% numElements = 10000;
% e = 1:numElements;
% f = (1:numElements)/10;
% 
% tic
% for a = 1:numElements
%     squared1(a) = e(a)^2+f(a)^2;
% end
% toc
% 
% tic
% a = 1:numElements; %important to create only once
% squared2 = e(a).^2 + f(a).^2;
% toc

% % Conclusion: vectorized is faster

%% Check matrix multiplication vs for loop
% numElements = 1000;
% perSparse = 0.1; % 10% filled matrix
% G = full(sprand(numElements,numElements,perSparse));
% e = rand(numElements,1);
% 
% m = 500;
% 
% temp1 = find(G(m,:)~=0); %nonzero indices of G(m,:);
% 
% % Matrix multiplication
% tic
% matmult1 = G(m,:)*e;
% toc
% 
% % For loop
% tic
% matmult2 = 0;
% for a = 1:size(temp1,2)
%     matmult2 = matmult2 + G(m,temp1(a))*e(temp1(a)); 
% end
% toc
% 
% % Conclusion: matrix multiplication is much faster than for loops!