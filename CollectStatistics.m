function CollectStatistics(DataSetStartIndex, DataSetEndIndex)  

    Methods = [cellstr('Random'), 'KShape'];
    Types = [cellstr('Zexact'), 'Ztop5', 'Ztop10', 'Ztop20', 'Z99per', 'Z95per', 'Z90per', 'Z85per', 'Z80per'];

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);
    
    %FourierEnergy = 1;
    %DatasetPercentile = 100;
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    %DS = LoadUCRdataset(char(Datasets(i)));
                    %disp([char(Datasets(i)),',',num2str(length(DS.ClassNames)),',',num2str(DS.TrainInstancesCount),',',num2str(DS.TestInstancesCount),',',num2str(length(DS.Train(1,:)))]);
                    
                    ResultsTmp = dlmread( strcat('RunLinearSVMRWS/','RunLinearSVMRWS', '_Dataset_', num2str(i)) );
                    
                    %ResultsTmp = dlmread( strcat( 'RunClassificationZREP/RunClassificationZREP_FULLKM_Z20_KShape_', num2str(i),'.results') );
                    %ResultsTmp = dlmread( strcat('RunOneNNTOPFFTED/', 'RunOneNNTOPFFTED_Dataset_', num2str(i), '_NumOfCoeff_',num2str(10)) );
                                        
                    Results(i,:) = ResultsTmp(i,:);
                    
            end
                    
           
    end
            
    dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/RESULTS_RunLinearSVMRWS_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex)), Results, 'delimiter', ',');
    
    %dlmwrite( strcat( '/rigel/dsi/users/ikp2103/JOPA/GRAIL2/RESULTS/RunOneNNTOPFFTED_NumOfCoeff_10_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex)), Results, 'delimiter', ',');
    
end
