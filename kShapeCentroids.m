function [mem,cent,iter,sumd, centKpp, centKppSmplPoints, DistValues, DistShifts,DistComp,RT1,DistComp2,RT2] = kShapeCentroids(A, K, Seeding)
% A = nXm : n # of time series; m length
% K clusters

DistComp=0;
DistComp2=0;
centKpp = [];
centKppSmplPoints = [];

n=size(A, 1);

if Seeding==1
    tic;
    [centKpp,centKppSmplPoints,DistComp2] = Seeding_SBD(A, K, 10);
    RT2 = toc;
    cent = centKpp;
    DistComp=DistComp+DistComp2;
    [~, ~, ~, mem] = Cent2Membership(A, cent, 2);
else
   mem = ceil(K*rand(n, 1)); 
   cent = zeros(K, size(A, 2));
end

%n=size(A, 1);
%mem = ceil(K*rand(m, 1));
%cent = zeros(K, size(A, 2));

DistValues = zeros(n,K);
DistShifts = zeros(n,K);
tic;
for iter = 1:100
    disp(iter);
    prev_mem = mem;
    
    for k = 1:K
        [centTmp,DistComp3] = kshape_centroid(mem, A, k, cent(k,:));  
        cent(k,:) = centTmp';
        %DistComp=DistComp+DistComp3; Computing it twice - this can be
        %optimized
    end
    
    for i = 1:n
        for k = 1:K
            
            [dist, shift, yshift]= SBD(A(i,:), zscore(cent(k,:)));
            DistComp=DistComp+1;
            DistValues(i,k) = dist;
            DistShifts(i,k) = shift;
            
        end
    end
    
    [val mem] = min(DistValues,[],2);
    sumd = sum(val);
    if norm(prev_mem-mem) == 0
        break;
    end
end
RT1 = toc;
end

function [ksc,DistComp] = kshape_centroid(mem, A, k, cur_center)
%Computes ksc centroid
a = [];
DistComp=0;
for i=1:length(mem)
    if mem(i) == k
        if sum(cur_center) == 0
            opt_a = A(i,:);
        else
             [~, ~, opt_a] = SBD(zscore(cur_center), A(i,:));
             DistComp=DistComp+1;
        end
        a = [a; opt_a];
    end
end

if size(a,1) == 0;
    %ksc = zeros(1, size(A,2));     
    permed_index = randperm(size(A,1));
    ksc = A(permed_index(1),:);
    return;
elseif size(a,1) == 1;
    ksc = a;
    return;
end

[~, ncolumns]=size(a);
[Y,~,~] = zscore(a,[],2);
P = (eye(ncolumns) - 1 / ncolumns * ones(ncolumns));
ksc = (sum(Y)*P)/norm(sum(Y)*P);

ksc = zscore(ksc);

end

function  [C,SmplPoints,DistComp] = Seeding_SBD(A, k, m)
% Calculate AFK-MC2 centers and distances, with correlation distance
% Usage: [centers] = kmc2(A, k, m)
%   A is d x n data matrix, where d is #objects and n is #timeperiods
%   k is desired numbered of centers
%   m is chain length (if <0, then expressed as percent of n timeperiods)
% Author: Terence Lim
% Original paper/code by Bachem, Lucic, Hassani and Krause "Fast and
%   Provably Good Seedings for k-Means"

  DistComp = 0;
  n = size(A,2);  % n columns of timeseries length
  d = size(A,1);  % d rows of objects
  if (m < 1)      % chain length expressed as % of objects
    m = ceil(m * d);
  end
  SmplPoints = [ceil(d * rand)];
  C = A(ceil(d * rand), :);    % sample first center

  q = Data2Centroids_SBD(A, C);   % compute proposal (already squared euclidean)
  
  DistComp = DistComp + size(A,1)*(size(C,1));
  
  q(find(isnan(q))) = 1;
  if (sum(q) == 0)
    q = repmat(1/d, size(q,1),size(q,2));
  else
    q = (q / sum(q)) + (1 / d); 
  end;
  q = q / sum(q);

  for i=1:(k-1)  % sequentially pick centers
    cand_ind = randsample(d, m, true, q);
    q_cand = q(cand_ind);                  % extract proposal probability
    p_cand = Data2Centroids_SBD(A(cand_ind,:), C);  % compute potentials
    
    DistComp = DistComp + size(A(cand_ind,:),1)*(size(C,1));
    
    rand_a = random('unif',0,1,m,1);       % compute acceptance probabilities
    for j=1:m                              % mix up to chain length m
      cand_prob = p_cand(j)/q_cand(j);
      if (j == 1 | curr_prob == 0.0 | cand_prob/curr_prob > rand_a(j))
        curr_ind = j;
        curr_prob = cand_prob;
      end
    end
    SmplPoints(i+1) = cand_ind(curr_ind);
    C(i+1,:) = A(cand_ind(curr_ind),:);
  end
end

function [vals, classes, distances, sumd] = Data2Centroids_SBD(A, c)
%   A is d x n data matrix
%   C is k x n centroids
%  Returns dx1 class labels, dxk distances to every center in c,
%   kx1 sumd within-cluster sum of distances
%  Author: Terence Lim

d = size(A,1);  % number of data objects
k = size(c,1);  % number of clusters
n = size(A,2);  % lengths of time series
distances = zeros(d,k);
sumd = zeros(k,1);

for i=1:d 
  %  if (rem(i,1000)==0) fprintf(1,'i=%d\n',i); end;
  for j=1:k
    [r shift] = max( NCCc(A(i,:),c(j,:)) );
    distances(i,j) = 1 - r;
  end
end
[vals, classes] = min(distances,[],2);
for i=1:k
  sumd(i,1) = sum(vals(classes==i));
end

end

function [SSError, MSError, STDError, labels] = Cent2Membership(A, Centroids, DistanceIndex)
%   A is d x n data matrix
%   Centroids is k x n centroids
%   Distance is 1 for ED and 2 for SBD
%   SSError is the sum of distances
%   labels is the cluster membership

d = size(A,1);  % number of data objects
k = size(Centroids,1);  % number of clusters

distances = zeros(d,k);

for i=1:d 
  for j=1:k
    if DistanceIndex==1
        distances(i,j) = ED(A(i,:),Centroids(j,:));
    elseif DistanceIndex==2
        distances(i,j) = 1-max(NCCc(A(i,:),Centroids(j,:)));
    end
  end
end

[vals, labels] = min(distances,[],2);

SSError = sum(vals);
MSError = mean(vals);
STDError = std(vals);

end
