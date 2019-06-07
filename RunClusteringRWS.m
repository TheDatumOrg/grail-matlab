function RunClusteringRWS(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);  
	
    Results = zeros(length(Datasets),2);
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    for rep = 1 : 10
                        rep
                        rng(rep);
                        
                        
                        % Extract Sample Points

                        %ZRep = dlmread( strcat( 'RWSREPRESENTATIONS','/',char(Datasets(i)),'/','RWS_Supervised', '.Zrep')  );
                        %ZRep = dlmread( strcat( 'RWSREPRESENTATIONS','/',char(Datasets(i)),'/','RWS_UNSupervised', '.Zrep')  );

                        %ZRep = dlmread( strcat( 'RWSREPRESENTATIONS','/',char(Datasets(i)),'/','RWS_UNSupervised_Sigma0.001_DMax25', '.Zrep')  );
                        %ZRep = dlmread( strcat( 'RWSREPRESENTATIONS','/',char(Datasets(i)),'/','RWS_UNSupervised_Sigma1_DMax100', '.Zrep')  );
                        ZRep = dlmread( strcat( 'RWSREPRESENTATIONS','/',char(Datasets(i)),'/','RWS_UNSupervised_Sigma1000_DMax25', '.Zrep')  );

                        tic;
                        
                        [mem cent] = kmeans(ZRep, length(DS.ClassNames),'Replicates',1);
                        
                        ClusteringTime = toc;

                        RI = RandIndex(mem, DS.DataClassLabels);
                        
                        % Evaluate SmplPoints in terms of clustering
                        % measures (e.g., SSE, RandIndex, NystromAppx)
                        
                        ResultsTmp = [RI,ClusteringTime];
                           
                        %
                        Results(i,:) = Results(i,:) + ResultsTmp;
                    end
                    Results(i,:) = Results(i,:) ./ 10;
                    
                    dlmwrite( strcat( 'RunClusteringRWS/','RunClusteringRWS_UNSupervised_Sigma1000_DMax25_Dataset_', num2str(i)), Results, 'delimiter', '\t');
   
            end
            
    end
    
end