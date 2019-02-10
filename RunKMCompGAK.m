function RunKMCompGAK(DataSetStartIndex, DataSetEndIndex, TrainKM, sigma)

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, ~] = sort(Datasets);

    disp(sigma);
    
    rng(DataSetStartIndex*sigma);
    pause(180*rand);
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    parpool(20);

    for i = 1:length(Datasets)
        
        if (i>=DataSetStartIndex && i<=DataSetEndIndex)
            
            Results = zeros(length(Datasets),4);
            
            disp(['Dataset being processed: ', char(Datasets(i))]);

            DS = LoadUCRdataset(char(Datasets(i)));

            % Sampling to estimate sigma appropriately
            dists = [];
            for l=1:20
                rng(l);
                x = DS.Train(ceil(rand*DS.TrainInstancesCount),:);
                y = DS.Train(ceil(rand*DS.TrainInstancesCount),:);
                w = [];
                for p=1:length(DS.Train(1,:))
                    w(p)= ED(x(p),y(p));
                end
                dists=[dists,w];
            end

            sigma2 = sigma*median(dists)*sqrt(length(DS.Train(1,:)));

            
            if (TrainKM==1)
                
                tic;
                [KMTrain, DistComp] = KMCompGAK(DS.Train,sigma2);
                Results(i,1) = DistComp; 
                Results(i,2) = toc;

                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/JOPA/GRAIL2/KernelMatricesGAK/',char(Datasets(i)),'/', char(Datasets(i)), '_GAK_Sigma_', num2str(sigma) ,'_TRAIN.kernelmatrix'), KMTrain, 'delimiter', '\t');
                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/JOPA/GRAIL2/RunKMCompGAK/', 'RunKMCompGAK_GAK_TrainToTrain_Sigma_', num2str(sigma), '_TrainToTrain_Dataset_' , num2str(i) ), Results, 'delimiter', '\t');


            else
                tic;
                [KMTestToTrain, DistComp2]= KMCompGAK_TestToTrain(DS.Test,DS.Train,sigma2);

                Results(i,3) = DistComp2;
                Results(i,4) = toc;
                
                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/JOPA/GRAIL2/KernelMatricesGAK/',char(Datasets(i)),'/', char(Datasets(i)), '_GAK_Sigma_', num2str(sigma) ,'_TESTTOTRAIN.kernelmatrix'), KMTestToTrain, 'delimiter', '\t');          
                dlmwrite( strcat( '/rigel/dsi/users/ikp2103/JOPA/GRAIL2/RunKMCompGAK/', 'RunKMCompGAK_GAK_TestToTrain_Sigma_', num2str(sigma), '_TestToTrain_Dataset_' , num2str(i) ), Results, 'delimiter', '\t');
 
                
            end

        end
        
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
end