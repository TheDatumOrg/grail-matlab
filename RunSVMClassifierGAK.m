function RunSVMClassifierGAK(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets); 
        
    Results = zeros(length(Datasets),13);

    addpath(genpath('SVMMatlab/.'));
    
    rng(ceil(DataSetStartIndex*100))
    pause(300*rand);
        
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    parpool(22);
    
    rng('default');
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));

                    %TrainInstancesCount = 1000;
                    %TrainClassLabels = DS.TrainClassLabels(1:1000);
                    
                    TrainInstancesCount = DS.TrainInstancesCount;
                    TrainClassLabels = DS.TrainClassLabels;

                    [Thebestgamma1,Thebestcost1,Thebestacc1,Thebestiming1] = GridSearchSVM1(-10,0.1,20,TrainInstancesCount,TrainClassLabels,Datasets,i);
                    
                    [Thebestgamma2,Thebestcost2,Thebestacc2,Thebestiming2] = GridSearchSVM2(Thebestcost1-2,0.01,Thebestcost1+2,TrainInstancesCount,TrainClassLabels,Datasets,i,Thebestgamma1);

                    [Thebestgamma3,Thebestcost3,Thebestacc3,Thebestiming3] = GridSearchSVM2(Thebestcost2-0.2,0.001,Thebestcost2+0.2,TrainInstancesCount,TrainClassLabels,Datasets,i,Thebestgamma1);

                    KM = dlmread( strcat( 'KernelMatricesGAK/',char(Datasets(i)),'/', char(Datasets(i)), '_GAK_Sigma_', num2str(Thebestgamma3) ,'_TRAIN.kernelmatrix') );

                    KMTrain = KM(1:DS.TrainInstancesCount,1:DS.TrainInstancesCount);
                      
                    tic;
                    cmd = ['-q -m 500 -t 4 -e 0.001 -c ', num2str(2^Thebestcost3)];
                    model_precomputed = svmtrain(DS.TrainClassLabels, [(1:DS.TrainInstancesCount)', KMTrain], cmd);
                    ModelTrainingRuntime = toc;

                    KM = dlmread( strcat( 'KernelMatricesGAK/',char(Datasets(i)),'/', char(Datasets(i)), '_GAK_Sigma_', num2str(Thebestgamma3) ,'_TESTTOTRAIN.kernelmatrix') );
                    
                    tic;
                    %[predict_label_P, accuracy_P, dec_values_P] = svmpredict(DS.TestClassLabels(1:1000), [(1:1000)', KM], model_precomputed);
                    [predict_label_P, accuracy_P, dec_values_P] = svmpredict(DS.TestClassLabels, [(1:DS.TestInstancesCount)', KM], model_precomputed);
                    PredictionRuntime = toc;
                                        
                    Results(i,1) = Thebestgamma1;
                    Results(i,2) = Thebestgamma2;
                    Results(i,3) = Thebestgamma3;
                    
                    Results(i,4) = Thebestcost1;
                    Results(i,5) = Thebestcost2;
                    Results(i,6) = Thebestcost3;
                    
                    Results(i,7) = Thebestacc1*0.01;
                    Results(i,8) = Thebestacc2*0.01;
                    Results(i,9) = Thebestacc3*0.01;

                    Results(i,10) = Thebestiming1+Thebestiming2+Thebestiming3;
                    
                    Results(i,11) = accuracy_P(1)*0.01;
                    Results(i,12) = ModelTrainingRuntime;
                    Results(i,13) = PredictionRuntime;
                    

            end
            dlmwrite( strcat('RunSVMClassifierGAK/','RunSVMClassifierGAK_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex)), Results, 'delimiter', '\t');
   
            
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
end

function [Thebestgamma,Thebestcost,Thebestacc,Thebestiming] = GridSearchSVM1(GridStart,GridStep,GridEnd,TrainInstancesCount,TrainClassLabels,Datasets,DatasetsNumber)


                    previousMaxbestacc = 0;
                    
                    Thebestgamma = 0;
                    Thebestcost = 0;
                    Thebestacc = 0;
                    Thebestiming = 0;
                    
                    WarpValues = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
                    

                    % Tuning Parameters
                    for gamma=1:20

                    gamma
                    log2cTmp = GridStart:GridStep:GridEnd; 

                    bestacc = zeros(1,length(log2cTmp));
                    bestgamma = zeros(1,length(log2cTmp));
                    bestcost = zeros(1,length(log2cTmp));
                    besttiming = zeros(1,length(log2cTmp));
                    
                      KM = dlmread( strcat( 'KernelMatricesGAK/',char(Datasets(DatasetsNumber)),'/', char(Datasets(DatasetsNumber)), '_GAK_Sigma_', num2str(WarpValues(gamma)) ,'_TRAIN.kernelmatrix') );
                    
                      KMTrain = KM(1:TrainInstancesCount,1:TrainInstancesCount);
                      
                      % grid search
                      parfor log2cNEW = 1:length(log2cTmp)
                        
                        log2cNEW
                        tic;
                        log2c = log2cTmp(log2cNEW);
                        cmd = ['-q -m 500 -t 4 -e 0.001 -v ' num2str(10) ' -c ', num2str(2^log2c)];
                        cv = svmtrain(TrainClassLabels, [(1:TrainInstancesCount)', KMTrain], cmd);
                        
                        bestacc(log2cNEW) = cv;
                        bestcost(log2cNEW) = log2c; 
                        bestgamma(log2cNEW) = WarpValues(gamma);
                        besttiming(log2cNEW) = toc;

                      end


                    [Maxbestacc,~] = max(bestacc);
                    Posbestacc = find(bestacc==Maxbestacc,1,'last');
                    
                    Thebestiming = Thebestiming+sum(besttiming);
                    
                    if Maxbestacc>previousMaxbestacc
                      
                        Thebestgamma = bestgamma(Posbestacc);
                        Thebestcost = bestcost(Posbestacc);
                        Thebestacc = Maxbestacc;
                        
                        
                        previousMaxbestacc = Maxbestacc;
                        
                    end
                    
                    
                    end



end

function [Thebestgamma,Thebestcost,Thebestacc,Thebestiming] = GridSearchSVM2(GridStart,GridStep,GridEnd,TrainInstancesCount,TrainClassLabels,Datasets,DatasetsNumber,gamma)


                    previousMaxbestacc = 0;
                    
                    Thebestgamma = 0;
                    Thebestcost = 0;
                    Thebestacc = 0;
                    Thebestiming = 0;

                    % Tuning Parameters

                    log2cTmp = GridStart:GridStep:GridEnd; 

                    bestacc = zeros(1,length(log2cTmp));
                    bestgamma = zeros(1,length(log2cTmp));
                    bestcost = zeros(1,length(log2cTmp));
                    besttiming = zeros(1,length(log2cTmp));
                    
                      KM = dlmread( strcat( 'KernelMatricesGAK/',char(Datasets(DatasetsNumber)),'/', char(Datasets(DatasetsNumber)), '_GAK_Sigma_', num2str(gamma) ,'_TRAIN.kernelmatrix') );
                    
                      KMTrain = KM(1:TrainInstancesCount,1:TrainInstancesCount);
                      
                      % grid search
                      parfor log2cNEW = 1:length(log2cTmp)
                        
                        log2cNEW
                        tic;
                        log2c = log2cTmp(log2cNEW);
                        cmd = ['-q -m 500 -t 4 -e 0.001 -v ' num2str(10) ' -c ', num2str(2^log2c)];
                        cv = svmtrain(TrainClassLabels, [(1:TrainInstancesCount)', KMTrain], cmd);
                          
                        bestacc(log2cNEW) = cv;
                        bestcost(log2cNEW) = log2c; 
                        bestgamma(log2cNEW) = gamma;
                        besttiming(log2cNEW) = toc;

                      end


                    [Maxbestacc,~] = max(bestacc);
                    Posbestacc = find(bestacc==Maxbestacc,1,'last');
                    
                    Thebestiming = Thebestiming+sum(besttiming);
                    
                    if Maxbestacc>previousMaxbestacc
                      
                        Thebestgamma = bestgamma(Posbestacc);
                        Thebestcost = bestcost(Posbestacc);
                        Thebestacc = Maxbestacc;
                        
                        
                        previousMaxbestacc = Maxbestacc;
                        
                    end
                    
                    
                    



end

