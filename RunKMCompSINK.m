function RunKMCompSINK(DataSetStartIndex, DataSetEndIndex, gamma)

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/tartarus/DATASETS/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, ~] = sort(Datasets);

    disp(gamma);
    
    for i = 1:length(Datasets)
        
        if (i>=DataSetStartIndex & i<=DataSetEndIndex)
            
            Results = zeros(length(Datasets),2);
            
            disp(['Dataset being processed: ', char(Datasets(i))]);

            DS = LoadUCRdataset(char(Datasets(i)));
            
            tic;
            
            [KM, DistComp] = KMCompSINK(DS.Data,gamma);

            Results(i,1) = DistComp;
            Results(i,2) = toc;
            
            dlmwrite( strcat( '/tartarus/jopa/Projects/UCR2018/KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(gamma) ,'.kernelmatrix'), KM, 'delimiter', '\t');
            dlmwrite( strcat( '/tartarus/jopa/Projects/GRAIL/RunKMCompSINK/', 'RunKMCompSINK_Gamma_', num2str(gamma), '_Dataset_' , num2str(i)), Results, 'delimiter', '\t');
   
        end
        
    end
    
end