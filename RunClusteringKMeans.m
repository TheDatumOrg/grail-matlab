function RunClusteringKMeans(DataSetStartIndex, DataSetEndIndex)  

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets); 
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex & i<=DataSetEndIndex)

                
                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    Results = zeros(length(Datasets),2);
                    
                    for rep = 1 : 10
                        rep
                        rng(rep);
                        
                        tic;
                        [mem cent] = kMeans(DS.Data, length(DS.ClassNames));
                        
                        ClusteringTime = toc;
                        
                        RI = RandIndex(mem, DS.DataClassLabels);
                        
                        ResultsTmp = [RI,ClusteringTime];
                           
                        %
                        Results(i,:) = Results(i,:) + ResultsTmp;
                    end
                    Results(i,:) = Results(i,:) ./ 10;
                    dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/RunClusteringKMeans/','RunClusteringKMeans_Dataset_', num2str(i)), Results, 'delimiter', '\t');
   
            end
            
            
    end
    
end