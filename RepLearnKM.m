function [Z99per,Z98per,Z97per,Z95per,Z90per,Z85per,Z80per,Ztop20,Ztop10,Ztop5,RepLearnTime]=RepLearnKM(KM)
% Input
% KM: Kernel matrix (nxn)
% Dim: Dimensions to keep in the end over the learned representation
% Output
% Ktilde: Approximated kernel matrix (nxn)
% Z: New learned representation (nxDim)

tic;
[Q,L]=eig(KM);

eigValue=diag(L);
[~,IX]=sort(eigValue,'descend');
eigVector=Q(:,IX);
eigValue=eigValue(IX);

VarExplainedCumSum = cumsum(eigValue)/sum(eigValue);

DimFor99 = find(VarExplainedCumSum>=0.99,1);
DimFor98 = find(VarExplainedCumSum>=0.98,1);
DimFor97 = find(VarExplainedCumSum>=0.97,1);
DimFor95 = find(VarExplainedCumSum>=0.95,1);
DimFor90 = find(VarExplainedCumSum>=0.90,1);
DimFor85 = find(VarExplainedCumSum>=0.85,1);
DimFor80 = find(VarExplainedCumSum>=0.80,1);

RepLearnTime = toc;

Z99per = CheckNaNInfComplex( eigVector(:,1:DimFor99)*sqrt(diag(eigValue(1:DimFor99))) );
Z98per = CheckNaNInfComplex( eigVector(:,1:DimFor98)*sqrt(diag(eigValue(1:DimFor98))) );
Z97per = CheckNaNInfComplex( eigVector(:,1:DimFor97)*sqrt(diag(eigValue(1:DimFor97))) );
Z95per = CheckNaNInfComplex( eigVector(:,1:DimFor95)*sqrt(diag(eigValue(1:DimFor95))) );
Z90per = CheckNaNInfComplex( eigVector(:,1:DimFor90)*sqrt(diag(eigValue(1:DimFor90))) );
Z85per = CheckNaNInfComplex( eigVector(:,1:DimFor85)*sqrt(diag(eigValue(1:DimFor85))) );
Z80per = CheckNaNInfComplex( eigVector(:,1:DimFor80)*sqrt(diag(eigValue(1:DimFor80))) );

Ztop20 = CheckNaNInfComplex( eigVector(:,1:20)*sqrt(diag(eigValue(1:20))) );
Ztop10 = CheckNaNInfComplex( eigVector(:,1:10)*sqrt(diag(eigValue(1:10))) );
Ztop5 = CheckNaNInfComplex( eigVector(:,1:5)*sqrt(diag(eigValue(1:5))) );

end

function Z = CheckNaNInfComplex(Z)

    for i=1:size(Z,1)
        for j=1:size(Z,2)
            if (isnan(Z(i,j)) || isinf(Z(i,j)) || ~isreal(Z(i,j))) 
                Z(i,j)=0;
                disp('ERROR ON REPRESENTATION');
            end
        end
    end

end
