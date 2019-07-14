function RunKMCompSINKSPLIT(DataSetStartIndex, DataSetEndIndex, TrainKM, sigma)

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, ~] = sort(Datasets);

    for i = 1:length(Datasets)
        
        if (i>=DataSetStartIndex && i<=DataSetEndIndex)
            
            Results = zeros(length(Datasets),4);
            
            disp(['Dataset being processed: ', char(Datasets(i))]);

            DS = LoadUCRdataset(char(Datasets(i)));
            
            if (TrainKM==1)
                
                tic;
                [KMTrain, DistComp] = KMCompSINK_TrainToTrain(DS.Train, sigma);

                Results(i,1) = DistComp; 
                Results(i,2) = toc;

                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/KernelMatricesSINKSPLIT/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Sigma_', num2str(sigma) ,'_TRAIN.kernelmatrix'), KMTrain, 'delimiter', '\t');
                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/RunKMCompSINKSPLIT/', 'RunKMCompSINKSPLIT_TrainToTrain_Sigma_', num2str(sigma), '_TrainToTrain_Dataset_' , num2str(i) ), Results, 'delimiter', '\t');


            else
                tic;
                [KMTestToTrain, DistComp2] = KMCompSINK_TestToTrain(DS.Test,DS.Train,sigma);

                Results(i,3) = DistComp2;
                Results(i,4) = toc;
                
                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/KernelMatricesSINKSPLIT/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Sigma_', num2str(sigma) ,'_TESTTOTRAIN.kernelmatrix'), KMTestToTrain, 'delimiter', '\t');          
                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/RunKMCompSINKSPLIT/', 'RunKMCompSINKSPLIT_TestToTrain_Sigma_', num2str(sigma), '_TestToTrain_Dataset_' , num2str(i) ), Results, 'delimiter', '\t');
 
                
            end

        end
        
    end
    
end