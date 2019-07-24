function [U,ProjData] = OriginalKPCA(K)
N=size(K,1);
K_Centered=K - (2/N)*ones(N,N)*K + ((1/N)*ones(N,N))*K*((1/N)*ones(N,N));

[U,L] = eig(K_Centered);

[va, dex] = sort(diag(L),'descend');
U = real(U(:, dex));

ProjData = K_Centered*U;

end