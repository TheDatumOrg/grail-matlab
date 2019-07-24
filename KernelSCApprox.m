function mem = KernelSCApprox(Z, k)

if size(Z,2)<k
    Z = padarray(Z,[0,abs(size(Z,2)-k-2)],0.0001*rand, 'post');
end

%Degree comp
ColumnSum = sum(Z,1);
DegMatrix = Z*ColumnSum';
DegMatrixinv = spdiags(DegMatrix.^(-0.5), 0, size(Z,1), size(Z,1));  
ZDegNorm = (DegMatrixinv'*Z);
disp('Degree Normalization Done..');

U = mySVD(ZDegNorm,k+1);
U(:,1) = [];
disp('Approximation of EigVector Done..');

U=U./repmat(sqrt(sum(U.^2,2)),1,size(U,2));

mem = kmeans(U,k);

disp('Done with kmeans');

end
