function [Variance,VarExplainedTop5,VarExplainedTop10,VarExplainedTop20,DimFor98,DimFor95,DimFor90,DimFor85,DimFor80,VarExplainedCumSum]=TestVarianceExact(KM)
              
    [nrowsKM, ncolumnsKM] = size(KM);

    KMtmp = [];
    for i=1:nrowsKM 
        KMtmp = [KMtmp, KM(i,:)];
    end
    
    Variance=var(KMtmp);
    clear KMtmp;
    
    [Q,L] = eig(KM);

    eigValue=diag(L);
    [~,IX]=sort(eigValue,'descend');
    eigVector=Q(:,IX);
    eigValue=eigValue(IX);

    VarExplainedCumSum = cumsum(eigValue)/sum(eigValue);

    VarExplainedTop5 = VarExplainedCumSum(5);
    VarExplainedTop10 = VarExplainedCumSum(10);
    VarExplainedTop20 = VarExplainedCumSum(20);

    DimFor98 = find(VarExplainedCumSum>=0.98,1);
    DimFor95 = find(VarExplainedCumSum>=0.95,1);
    DimFor90 = find(VarExplainedCumSum>=0.90,1);
    DimFor85 = find(VarExplainedCumSum>=0.85,1);
    DimFor80 = find(VarExplainedCumSum>=0.80,1);

end