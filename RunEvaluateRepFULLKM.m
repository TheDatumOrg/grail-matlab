function RunEvaluateRepFULLKM(DataSetStartIndex, DataSetEndIndex, gamma)  

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);    
	
    Results = zeros(length(Datasets),32);
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex & i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    % Get Kernel Matrix
                    
                    KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(gamma) ,'.kernelmatrix') );
                    
                    ZFULLKM98 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z98per') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKM98*ZFULLKM98');
                    Results(i,1) = AbsFroError;
                    Results(i,2) = RelFroError;
                    Results(i,3) = NormFroError;
                    Results(i,4) = size(ZFULLKM98,2);
                    
                    ZFULLKM95 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z95per') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKM95*ZFULLKM95');
                    Results(i,5) = AbsFroError;
                    Results(i,6) = RelFroError;
                    Results(i,7) = NormFroError;
                    Results(i,8) = size(ZFULLKM95,2);
                    
                    ZFULLKM90 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z90per') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKM90*ZFULLKM90');
                    Results(i,9) = AbsFroError;
                    Results(i,10) = RelFroError;
                    Results(i,11) = NormFroError;
                    Results(i,12) = size(ZFULLKM90,2);
                    
                    ZFULLKM85 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z85per') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKM85*ZFULLKM85');
                    Results(i,13) = AbsFroError;
                    Results(i,14) = RelFroError;
                    Results(i,15) = NormFroError;
                    Results(i,16) = size(ZFULLKM85,2);
                    
                    ZFULLKM80 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z80per') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKM80*ZFULLKM80');
                    Results(i,17) = AbsFroError;
                    Results(i,18) = RelFroError;
                    Results(i,19) = NormFroError;
                    Results(i,20) = size(ZFULLKM80,2);
                    
                    ZFULLKMZ5 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z5') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKMZ5*ZFULLKMZ5');
                    Results(i,21) = AbsFroError;
                    Results(i,22) = RelFroError;
                    Results(i,23) = NormFroError;
                    Results(i,24) = size(ZFULLKMZ5,2);
                    
                    ZFULLKMZ10 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z10') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKMZ10*ZFULLKMZ10');
                    Results(i,25) = AbsFroError;
                    Results(i,26) = RelFroError;
                    Results(i,27) = NormFroError;
                    Results(i,28) = size(ZFULLKMZ10,2);
                    
                    ZFULLKMZ20 = dlmread( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z20') );
                    
                    [AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKMZ20*ZFULLKMZ20');
                    Results(i,29) = AbsFroError;
                    Results(i,30) = RelFroError;
                    Results(i,31) = NormFroError;
                    Results(i,32) = size(ZFULLKMZ20,2);
                    
                    %[AbsFroError,RelFroError,NormFroError] = RepEval(KM,ZFULLKM98*ZFULLKM98');
                    
                    %ResultsTmp = [AbsFroError,RelFroError,NormFroError];
                          
                        %
                    %Results(i,1:3) = RepEval(KM,ZFULLKM98*ZFULLKM98');
                    %Results(i,4:6) = RepEval(KM,ZFULLKM95*ZFULLKM95');
                    %Results(i,7:9) = RepEval(KM,ZFULLKM90*ZFULLKM90');
                    %Results(i,10:12) = RepEval(KM,ZFULLKM85*ZFULLKM85');
                    %Results(i,13:15) = RepEval(KM,ZFULLKM80*ZFULLKM80');
           
            end
            
            dlmwrite( strcat( 'RunEvaluateRepFULLKM/','RESULTS_RunEvaluateRepFULLKM_', num2str(gamma), '_' ,num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex) ,'.results'), Results, 'delimiter', '\t');
   
    end
    
end

function [AbsFroError,RelFroError,NormFroError] = RepEval(KM,KMtilde)

num_rows = size(KM,1);

AbsFroError = ( norm(KM-KMtilde,'fro') );
RelFroError = 0;
NormFroError = 0;
%RelFroError = ( norm(KM-KMtilde,'fro')/norm(KM,'fro') );
%NormFroError = ( norm(KM-KMtilde,'fro')/num_rows^2);

end