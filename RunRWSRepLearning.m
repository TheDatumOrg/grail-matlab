function RunRWSRepLearning(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);  
    
    addpath(genpath('RWS/.'));
    addpath(genpath('RWS/utilities/.'));
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    display(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    NumOfSamples = min(max( [4*length(DS.ClassNames), ceil(0.4*DS.DataInstancesCount),20] ),100);

                    %ZRep = SPIRALRepLearning(DS, NumOfSamples); 
                    
                    % Supervised Tuning
                    info = RWSTuneParameters(DS,NumOfSamples);
                    ZRepSup = RWSRepLearning(DS,info.sigma,NumOfSamples,1,info.DMax);
                    
                    % Without Tuning for Clustering
                    ZRepUNSup = RWSRepLearning(DS,1,NumOfSamples,1,25);
                    %ZRepUNSup = RWSRepLearning(DS,1000,NumOfSamples,1,25);
                    
                    dlmwrite( strcat( 'RWSREPRESENTATIONS','/',char(Datasets(i)),'/','RWS_Supervised', '.Zrep'), ZRepSup, 'delimiter', '\t');
                    dlmwrite( strcat( 'RWSREPRESENTATIONS','/',char(Datasets(i)),'/','RWS_UNSupervised_Sigma1000_DMax25', '.Zrep'), ZRepUNSup, 'delimiter', '\t');
                            
                                   
                                    
            end
            
            
    end
    
    
end
