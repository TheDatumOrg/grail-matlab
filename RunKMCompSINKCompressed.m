function RunKMCompSINKCompressed(DataSetStartIndex, DataSetEndIndex, gamma, FourierEnergy, DatasetPercentile)

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, ~] = sort(Datasets);

    disp(gamma);
    
    for i = 1:length(Datasets)
        
        if (i>=DataSetStartIndex & i<=DataSetEndIndex)
            
            Results = zeros(length(Datasets),2);
            
            disp(['Dataset being processed: ', char(Datasets(i))]);

            DS = LoadUCRdataset(char(Datasets(i)));
            
            % Estimating required number of coefficients to
            % guarantee energy level between comparisons
            DSFourier = DatasetToFourier(DS, FourierEnergy, DatasetPercentile);
                    
            tic;
            
            [KM, DistComp] = KMCompSINKCompressed(DS.Data,gamma,DSFourier.NumCoeffs);

            Results(i,1) = DistComp;
            Results(i,2) = toc;
            
            dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/KernelMatricesSINKCompressed/',char(Datasets(i)),'/', char(Datasets(i)), '_SINKComp_Gamma_', num2str(gamma) ,'.kernelmatrix'), KM, 'delimiter', '\t');
            dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/RunKMCompSINKCompressed/', 'RunKMCompSINKCompE99D100_Gamma_', num2str(gamma), '_Dataset_' , num2str(i)), Results, 'delimiter', '\t');
   
        end
        
    end
    
end