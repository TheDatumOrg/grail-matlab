function [AbsFroError,RelFroError,NormFroError] = NystromMatrixDictionary(KM, X, Dictionary, gamma)
% KM: nXn kernel matrix, where n # of time series of m length
% Dictionary: kxm matrxi containing the dictionary atoms
% Absolute and Relative errors for Nystrom Approximation
[nrowsX, ncolumnsX] = size(X);
[nrowsDic, ncolumnsDic] = size(Dictionary);

W = zeros(nrowsDic,nrowsDic);

for i=1:nrowsDic
    for j=1:nrowsDic
        W(i,j) = SINK(Dictionary(i,:),Dictionary(j,:),gamma);
    end    
end
        
E = zeros(nrowsX,nrowsDic);

for i=1:nrowsX
       for j=1:nrowsDic
           E(i,j) = SINK(X(i,:),Dictionary(j,:),gamma);
       end    
end

[Ve, Va] = eig(W);
va = diag(Va);
inVa = diag(va.^(-0.5));

Zexact = CheckNaNInfComplex( E * Ve * inVa );

KMtilde = Zexact*Zexact';

AbsFroError = ( norm(KM-KMtilde,'fro') );
RelFroError = ( norm(KM-KMtilde,'fro')/norm(KM,'fro') );
NormFroError = ( norm(KM-KMtilde,'fro')/nrowsX^2);

end

function Z = CheckNaNInfComplex(Z)

    for i=1:size(Z,1)
        for j=1:size(Z,2)
            if (isnan(Z(i,j)) || isinf(Z(i,j)) || ~isreal(Z(i,j))) 
                Z(i,j)=0;
            end
        end
    end

end