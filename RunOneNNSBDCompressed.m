function RunOneNNSBDCompressed(DataSetStartIndex, DataSetEndIndex, FourierEnergy, DatasetPercentile)  
% FourierEnergy is like 0.9    
% DatasetPercentile is like 99

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);  
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    Results = zeros(length(Datasets),7);
                
                    display(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    % Estimating required number of coefficients to
                    % guarantee energy level between comparisons
                    DSFourier = DatasetToFourier(DS, FourierEnergy, DatasetPercentile);
                    
                    tic;
                    OneNNAcc = OneNNClassifierSBDCompressed(DS,DSFourier.NumCoeffs);
                    
                    Results(i,1) = FourierEnergy;
                    Results(i,2) = DatasetPercentile;
                    Results(i,3) = DSFourier.len;
                    Results(i,4) = DSFourier.fftlength;
                    Results(i,5) = DSFourier.NumCoeffs;
                    Results(i,6) = OneNNAcc;
                    Results(i,7) = toc;
                    
                    dlmwrite( strcat('/rigel/dsi/users/ikp2103/VLDBGRAIL/RunOneNNSBDCompressed/', 'RunOneNNSBD_Dataset_', num2str(i),'_DatasetPercentile_',num2str(DatasetPercentile),'_FourierEnergy_',num2str(FourierEnergy) ), Results, 'delimiter', '\t');
   
            end
            
            
    end
    
end