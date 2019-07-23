function Results = TestVarianceApproximate(Dictionary)
              
[nrowsDic, ncolumnsDic] = size(Dictionary);

W = zeros(nrowsDic,nrowsDic);

Var4Gamma = zeros(1,20);
VarExplained20 = zeros(1,20);

DimFor98 = zeros(1,20);
DimFor95 = zeros(1,20);
DimFor90 = zeros(1,20);
DimFor85 = zeros(1,20);
DimFor80 = zeros(1,20);

for g=1:20
    g
    Wtmp = [];
    for i=1:nrowsDic
        %disp(i);
        for j=1:nrowsDic
            W(i,j) = SINK(Dictionary(i,:),Dictionary(j,:),g);
        end    
        Wtmp = [Wtmp, W(i,:)];
    end

    Var4Gamma(g)=var(Wtmp);
    
    [Q,L] = eig(W);

    eigValue=diag(L);
    [~,IX]=sort(eigValue,'descend');
    eigVector=Q(:,IX);
    eigValue=eigValue(IX);
    
    VarExplainedCumSum = cumsum(eigValue)/sum(eigValue);
    
    VarExplained20(g) = VarExplainedCumSum(20);

    DimFor98(g) = find(VarExplainedCumSum>=0.98,1);
    DimFor95(g) = find(VarExplainedCumSum>=0.95,1);
    DimFor90(g) = find(VarExplainedCumSum>=0.90,1);
    DimFor85(g) = find(VarExplainedCumSum>=0.85,1);
    DimFor80(g) = find(VarExplainedCumSum>=0.80,1); 
end

VarByVarExplained20 = Var4Gamma.*VarExplained20;

[~, GammaForMaxVariance] = max(Var4Gamma);
[~, GammaForMaxVarByVarExplained20] = max(VarByVarExplained20);

Results = [];

MaxVarExpained20 = VarExplained20(GammaForMaxVariance);
MaxVarDimFor98 = DimFor98(GammaForMaxVariance);
MaxVarDimFor95 = DimFor95(GammaForMaxVariance);
MaxVarDimFor90 = DimFor90(GammaForMaxVariance);
MaxVarDimFor85 = DimFor85(GammaForMaxVariance);
MaxVarDimFor80 = DimFor80(GammaForMaxVariance);

Results = [Results,GammaForMaxVariance,MaxVarExpained20,MaxVarDimFor98,MaxVarDimFor95,MaxVarDimFor90,MaxVarDimFor85,MaxVarDimFor80];

MaxVarByVarExpained20 = VarExplained20(GammaForMaxVarByVarExplained20);
MaxVarByVarExpDimFor98 = DimFor98(GammaForMaxVarByVarExplained20);
MaxVarByVarExpDimFor95 = DimFor95(GammaForMaxVarByVarExplained20);
MaxVarByVarExpDimFor90 = DimFor90(GammaForMaxVarByVarExplained20);
MaxVarByVarExpDimFor85 = DimFor85(GammaForMaxVarByVarExplained20);
MaxVarByVarExpDimFor80 = DimFor80(GammaForMaxVarByVarExplained20);

Results = [Results,GammaForMaxVarByVarExplained20,MaxVarByVarExpained20,MaxVarByVarExpDimFor98,MaxVarByVarExpDimFor95,MaxVarByVarExpDimFor90,MaxVarByVarExpDimFor85,MaxVarByVarExpDimFor80];

end