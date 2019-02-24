function RunOneNNSINKCompressed(DataSetStartIndex, DataSetEndIndex, FourierEnergy, DatasetPercentile)  
% FourierEnergy is percentage e.g., 0.99
% DatasetPercentile is percentage in the form of 99, 95 etc.

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);  
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    LeaveOneOutAccuracies = zeros(length(Datasets),20);
                    LeaveOneOutRuntimes = zeros(length(Datasets),20);
                    
                    Results = zeros(length(Datasets),10);
                
                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    tic;
                    
                    DSFourier = DatasetToFourier(DS, FourierEnergy, DatasetPercentile);
                    
                    RTPreprocessing = toc;
                    
                    gammaValues = 1:20;
                    
                    %parfor gamma = 1:20
                    for gammaIter = 1:20

                        gammaIter
                        tic;
                        acc = LOOCSINKCompressed(DSFourier,gammaValues(gammaIter));
                        LeaveOneOutRuntimes(i,gammaIter) = toc;
                        LeaveOneOutAccuracies(i,gammaIter) = acc;
                    end
                    
                    [MaxLeaveOneOutAcc,MaxLeaveOneOutAccGamma] = max(LeaveOneOutAccuracies(i,:));

                    tic;
                    OneNNAcc = OneNNClassifierSINKCompressed(DSFourier, gammaValues(MaxLeaveOneOutAccGamma));
                    
                    RTOneNN = toc;
                    
                    Results(i,1) = DSFourier.len;
                    Results(i,2) = DSFourier.fftlength;
                    Results(i,3) = DSFourier.NumCoeffs;
                    
                    Results(i,4) = RTPreprocessing;
                    
                    Results(i,5) = gammaValues(MaxLeaveOneOutAccGamma);
                    Results(i,6) = MaxLeaveOneOutAcc;
                    Results(i,7) = LeaveOneOutRuntimes(i,MaxLeaveOneOutAccGamma);
                    Results(i,8) = sum(LeaveOneOutRuntimes(i,:));
                    Results(i,9) = RTOneNN;
                    Results(i,10) = OneNNAcc;
                    
                    dlmwrite( strcat('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/RunOneNNSINKCompressed/', 'RESULTS_RunOneNNSINKCompressed_FourierEnergy_', num2str(FourierEnergy), '_DatasetPercentile_', num2str(DatasetPercentile), '_Dataset_' ,num2str(i)), Results, 'delimiter', '\t');
   
            end
            
            
    end
    
end