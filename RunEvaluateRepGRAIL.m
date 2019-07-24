function RunEvaluateRepGRAIL(DataSetStartIndex, DataSetEndIndex, Method, gamma)  
        
    Methods = [cellstr('Random'), 'KShape'];

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);    
	
    Results = zeros(length(Datasets),36);
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex & i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    % Get Kernel Matrix
                    
                    KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(gamma) ,'.kernelmatrix') );
                    
                    for rep = 1 : 1
                        rep
                        rng(rep);
                        
                    ZExact = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Zexact') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZExact*ZExact');
                    Results(i,1) = Results(i,1)+AbsFroError;
                    Results(i,2) = Results(i,2)+RelFroError;
                    Results(i,3) = Results(i,3)+NormFroError;
                    Results(i,4) = Results(i,4)+size(ZExact,2);
                    
                    Z99per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z99per') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Z99per*Z99per');
                    Results(i,5) = Results(i,5)+AbsFroError;
                    Results(i,6) = Results(i,6)+RelFroError;
                    Results(i,7) = Results(i,7)+NormFroError;
                    Results(i,8) = Results(i,8)+size(Z99per,2);
                    
                    Z98per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z98per') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Z98per*Z98per');
                    Results(i,9) = Results(i,9)+AbsFroError;
                    Results(i,10) = Results(i,10)+RelFroError;
                    Results(i,11) = Results(i,11)+NormFroError;
                    Results(i,12) = Results(i,12)+size(Z98per,2);
                    
                    Z97per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z97per') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Z97per*Z97per');
                    Results(i,13) = Results(i,13)+AbsFroError;
                    Results(i,14) = Results(i,14)+RelFroError;
                    Results(i,15) = Results(i,15)+NormFroError;
                    Results(i,16) = Results(i,16)+size(Z97per,2);
                    
                    Z95per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z95per') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Z95per*Z95per');
                    Results(i,17) = Results(i,17)+AbsFroError;
                    Results(i,18) = Results(i,18)+RelFroError;
                    Results(i,19) = Results(i,19)+NormFroError;
                    Results(i,20) = Results(i,20)+size(Z95per,2);
                    
                    Z90per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z90per') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Z90per*Z90per');
                    Results(i,21) = Results(i,21)+AbsFroError;
                    Results(i,22) = Results(i,22)+RelFroError;
                    Results(i,23) = Results(i,23)+NormFroError;
                    Results(i,24) = Results(i,24)+size(Z90per,2);
                    
                    Ztop5 = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop5') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Ztop5*Ztop5');
                    Results(i,25) = Results(i,25)+AbsFroError;
                    Results(i,26) = Results(i,26)+RelFroError;
                    Results(i,27) = Results(i,27)+NormFroError;
                    Results(i,28) = Results(i,28)+size(Ztop5,2);
                    
                    Ztop10 = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop10') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Ztop10*Ztop10');
                    Results(i,29) = Results(i,29)+AbsFroError;
                    Results(i,30) = Results(i,30)+RelFroError;
                    Results(i,31) = Results(i,31)+NormFroError;
                    Results(i,32) = Results(i,32)+size(Ztop10,2);
                   
                    Ztop20 = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop20') );
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,Ztop20*Ztop20');
                    Results(i,33) = Results(i,33)+AbsFroError;
                    Results(i,34) = Results(i,34)+RelFroError;
                    Results(i,35) = Results(i,35)+NormFroError;
                    Results(i,36) = Results(i,36)+size(Ztop20,2);
                    
                    end
                    
            end
                    Results(i,:) = Results(i,:) ./ 1;

    end
            
    dlmwrite( strcat( 'RunEvaluateRepGRAIL/','RESULTS_RunEvaluateRepGRAIL_', char(Methods(Method)), '_', num2str(gamma), '_' ,num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex) ,'.results'), Results, 'delimiter', '\t');
   
end
    

function [AbsFroError,RelFroError,NormFroError] = RepEval(KM,KMtilde)

num_rows = size(KM,1);

AbsFroError = ( norm(KM-KMtilde,'fro') );
RelFroError = 0;
NormFroError = 0;

%RelFroError = ( norm(KM-KMtilde,'fro')/norm(KM,'fro') );
%NormFroError = ( norm(KM-KMtilde,'fro')/num_rows^2);

end