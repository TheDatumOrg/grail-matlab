function RunOneNNDTW(DataSetStartIndex, DataSetEndIndex,WindowPercent)  
    
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
                    
                    % warping window
                    TSLength = length(DS.Data(1,:));
                    window = floor(WindowPercent/100 * TSLength); 
                    
                    tic;
                    OneNNAcc = OneNNClassifierDTW(DS,window);
                    
                    Results(i,1) = OneNNAcc;
                    Results(i,2) = toc;
   
                    dlmwrite( strcat('/rigel/dsi/users/ikp2103/VLDBGRAIL/RunOneNNDTW/', 'RunOneNNDTW_Dataset_', num2str(i), '_WindowPercent_', num2str(WindowPercent)), Results, 'delimiter', '\t');

            end
            
            
    end
    
end