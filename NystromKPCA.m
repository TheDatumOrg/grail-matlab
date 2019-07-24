function [V,ProjData] = NystromKPCA(Z)

Z = Z - repmat(mean(Z), size(Z,1), 1);

[BSketch, ~] = FrequentDirections(Z, ceil(0.5*size(Z,2)));
NewL = BSketch'*BSketch;

[U,L] = eig(NewL);

V = Z * U * L^(-1/2);
[va, dex] = sort(diag(L),'descend');
V = real(V(:, dex));

ProjData = Z*U;



end