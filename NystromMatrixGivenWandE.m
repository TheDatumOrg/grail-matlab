function [AbsFroError,RelFroError,NormFroError] = NystromMatrixGivenWandE(KM, C, Winv)
% KM: nXn kernel matrix, where n # of time series of m length
% Dictionary: kxm matrxi containing the dictionary atoms
% Absolute and Relative errors for Nystrom Approximation
[nrowsX, ncolumnsX] = size(KM);

KMtilde = C*Winv*C';

AbsFroError = ( norm(KM-KMtilde,'fro') );
RelFroError = ( norm(KM-KMtilde,'fro')/norm(KM,'fro') );
NormFroError = ( norm(KM-KMtilde,'fro')/nrowsX^2);

end
