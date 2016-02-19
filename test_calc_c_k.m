clc
clear all

example_14bus_IEEE_rectADMM    

busIndex = (1:14).';
iter = 0;

x1_k = [allbuses1; allbuses1(2:size(allbuses1,1))];
x2_k = [allbuses2; 2*allbuses2];
x3_k = [allbuses3; 2*allbuses3];
x4_k = [allbuses4; 2*allbuses4];

numPart = zeros(numbus*2,1);
c_k = zeros(numbus*2,1);

% Match each state vector with global indexing
for a = 1:size(allbuses1,1)
    numPart(allbuses1(a)) = numPart(allbuses1(a))+1;
    c_k(allbuses1(a),iter+1) = c_k(allbuses1(a),iter+1)+x1_k(a,iter+1);
end
% Assumes slack bus is bus 1 and in Partition 1
for a = 2:size(allbuses1,1)
    numPart(numbus+allbuses1(a)) = numPart(numbus+allbuses1(a))+1;
    c_k(numbus+allbuses1(a),iter+1) = c_k(numbus+allbuses1(a),iter+1)+x1_k(size(allbuses1,1)+a-1,iter+1); 
end
for a = 1:size(allbuses2,1)
    numPart(allbuses2(a)) = numPart(allbuses2(a))+1;
    numPart(numbus+allbuses2(a)) = numPart(numbus+allbuses2(a))+1;
    c_k(allbuses2(a),iter+1) = c_k(allbuses2(a),iter+1)+x2_k(a,iter+1);
    c_k(numbus+allbuses2(a),iter+1) = c_k(numbus+allbuses2(a),iter+1)+x2_k(size(allbuses2,1)+a,iter+1);
end
for a = 1:size(allbuses3,1)
    numPart(allbuses3(a)) = numPart(allbuses3(a))+1;
    numPart(numbus+allbuses3(a)) = numPart(numbus+allbuses3(a))+1;
    c_k(allbuses3(a),iter+1) = c_k(allbuses3(a),iter+1)+x3_k(a,iter+1);
    c_k(numbus+allbuses3(a),iter+1) = c_k(numbus+allbuses3(a),iter+1)+x3_k(size(allbuses3,1)+a,iter+1);
end
for a = 1:size(allbuses4,1)
    numPart(allbuses4(a)) = numPart(allbuses4(a))+1;
    numPart(numbus+allbuses4(a)) = numPart(numbus+allbuses4(a))+1;
    c_k(allbuses4(a),iter+1) = c_k(allbuses4(a),iter+1)+x4_k(a,iter+1);
    c_k(numbus+allbuses4(a),iter+1) = c_k(numbus+allbuses4(a),iter+1)+x4_k(size(allbuses4,1)+a,iter+1);    
end
for a = 1:numbus*2
    if numPart(a) ~= 0
        c_k(a,iter+1) = c_k(a,iter+1)/numPart(a);
    end
end
