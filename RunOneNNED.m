function RunOneNNED(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);

    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    Results = zeros(length(Datasets),2);

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    tic;
                    OneNNAcc = OneNNClassifierED(DS);
                    
                    Results(i,1) = OneNNAcc;
                    Results(i,2) = toc;
   
                    dlmwrite( strcat('/rigel/dsi/users/ikp2103/VLDBGRAIL/RunOneNNED/', 'RunOneNNED_Dataset_', num2str(i)), Results, 'delimiter', '\t');
   
            end
            
            
    end
    
end

