function [mem cent] = kShape(A, K)

m=size(A, 1);
mem = ceil(K*rand(m, 1));
cent = zeros(K, size(A, 2));

for iter = 1:100
    disp(iter);
    prev_mem = mem;

    for k = 1:K
        cent(k,:) = kshape_centroid(mem, A, k, cent(k,:));    
        cent(k,:) = zscore(cent(k,:));
    end
    
    for i = 1:m
        
        %x = A(i,:);
        for k = 1:K
            %y = cent(k,:);
            dist = 1-max( NCCc( A(i,:), cent(k,:)) );
            D(i,k) = dist;
        end
    end

    [val mem] = min(D,[],2);
    if norm(prev_mem-mem) == 0
        break;
    end
end

end

function ksc = kshape_centroid(mem, A, k, cur_center)
% Slower version
%Computes ksc centroid
%a = [];
%for i=1:length(mem)
%    if mem(i) == k
%        if sum(cur_center) == 0
%            opt_a = A(i,:);
%        else
%             [tmp tmps opt_a] = SBD(zscore(cur_center), A(i,:));
%        end
%        a = [a; opt_a];
%    end
%end

a = A(mem==k,:);

if sum(cur_center) ~= 0
    for i=1:size(a,1)
    [tmp tmps opt_a] = SBD(cur_center, a(i,:));
    a(i,:) = opt_a;
    end
   
end

if size(a,1) == 0
    ksc = zeros(1, size(A,2));
    return;
end

[m, ncolumns]=size(a);
[Y mean2 std2] = zscore(a,[],2);
S = Y' * Y;
P = (eye(ncolumns) - 1 / ncolumns * ones(ncolumns));
M = P*S*P;
[V D] = eigs(M,1);
ksc = V(:,1);

finddistance1 = sqrt(sum((a(1,:) - ksc').^2));
finddistance2 = sqrt(sum((a(1,:) - (-ksc')).^2));

if (finddistance1<finddistance2)
    ksc = ksc;
else
    ksc = -ksc;
end

end
