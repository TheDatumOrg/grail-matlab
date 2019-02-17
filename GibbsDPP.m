function [C,DistComp] = GibbsDPP(L, mixStep, k)
% sampling subsets from (Gibbs) Markov chain k-DPP with Gauss quadrature
%
% -input
%   L: data kernel matrix, N*N where N is number of samples
%   mixStep: number of burn-in iterations
%   k: the size of sampled subset
%
% -output
%   C: sampled subset
%
% sample usage:
%   C = GibbsDPP(L,1000,5)

addpath(genpath('GibbsDPP/.'));

permed_index = randperm(size(L,1));
sample_data = permed_index(1:k);

[C,DistComp] = gauss_kdpp(L, k, @gershgorin, mixStep, sample_data);
C = sort(C, 'ascend');
end

