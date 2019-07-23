function RunTestVarianceExact(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);   
    
    Results = zeros(length(Datasets),55);
    
    %rng(ceil(DataSetStartIndex*100))
    %pause(300*rand);
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    parpool(10);
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex & i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                                       
                    VarExplainedCumSumMatrix = zeros(20,DS.DataInstancesCount);
                    StatisticsForGamma = zeros(20,14);
                    
                    parfor gamma = 1 : 20
                        
                        gamma
                        rng(gamma);
                  
                        KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(gamma) ,'.kernelmatrix'));
                        
                        [Variance,VarExplainedTop5,VarExplainedTop10,VarExplainedTop20,DimFor98,DimFor95,DimFor90,DimFor85,DimFor80,VarExplainedCumSum]=TestVarianceExact(KM);
                        
                        Z20 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z20') );
                        Z90per = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z90per') );
                        
                        LOOCAccuracyZ20 = LeaveOneOutClassifierZREP(DS,Z20);
                        LOOCAccuracyZ90per = LeaveOneOutClassifierZREP(DS,Z90per);
                        
                        OneNNAccuracyZ20 = OneNNClassifierZREP(DS,Z20);
                        OneNNAccuracyZ90per = OneNNClassifierZREP(DS,Z90per);
                        
                        VarExplainedCumSumMatrix(gamma,:) = VarExplainedCumSum;
                        StatisticsForGamma(gamma,:) = [Variance,VarExplainedTop5,VarExplainedTop10,VarExplainedTop20,DimFor98,DimFor95,DimFor90,DimFor85,DimFor80,trapz(1:size(KM,1),VarExplainedCumSum),LOOCAccuracyZ20,LOOCAccuracyZ90per,OneNNAccuracyZ20,OneNNAccuracyZ90per];

                    end

                    dlmwrite( strcat('RunTestVarianceExactVarExplainedCumSum/','RESULTS_RunTestVarianceExactVarExplainedCumSum_', num2str(i)), VarExplainedCumSumMatrix, 'delimiter', '\t');
                    dlmwrite( strcat('RunTestVarianceExactStatisticsForGamma/','RESULTS_RunTestVarianceExactStatisticsForGamma_', num2str(i)), StatisticsForGamma, 'delimiter', '\t');
   
                    
            end
            
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
end