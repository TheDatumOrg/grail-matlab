function RunDMComp(DataSetStartIndex, DataSetEndIndex, DistanceIndex)

    % Distance Matrices for ED and SBD
    Methods = [cellstr('ED'), 'SBD'];

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, ~] = sort(Datasets);
    
    for i = 1:length(Datasets)
        
        if (i>=DataSetStartIndex && i<=DataSetEndIndex)
            
            Results = zeros(length(Datasets),2);
            
            disp(['Dataset being processed: ', char(Datasets(i))]);
            DS = LoadUCRdataset(char(Datasets(i)));
                    
            tic;
            
            [DM, DistComp] = DMComp(DS.Data, DistanceIndex);
            
            Results(i,1) = DistComp;
            Results(i,2) = toc;
            
            dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/DistanceMatrices/',char(Datasets(i)),'/', char(Datasets(i)),'_',char(Methods(DistanceIndex)),'.distmatrix'), DM, 'delimiter', '\t');
            dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/RunDMComp/', 'RunDMComp_', char(Methods(DistanceIndex)), '_Dataset_', num2str(i) ), Results, 'delimiter', '\t');
   
        end
        
    end

end