function RunSPIRALRepLearning(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);  
    
    addpath(genpath('SPIRAL/.'));
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    display(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    NumOfSamples = min(max( [4*length(DS.ClassNames), ceil(0.4*DS.DataInstancesCount),20] ),100);

                    [ZRep,~,~]= SPIRALRepLearning(DS, NumOfSamples); 
                    dlmwrite( strcat( 'SPIRALREPRESENTATIONS','/',char(Datasets(i)),'/','SIDLREPRESENTATIONS', '.Zrep'), ZRep, 'delimiter', '\t');
                            
                                   
                                    
            end
            
            
    end
    
    
end
