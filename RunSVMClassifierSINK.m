function RunSVMClassifierSINK(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets); 
        
    Results = zeros(length(Datasets),14);
    
    addpath(genpath('SVMMatlab/.'));
    
    rng(ceil(DataSetStartIndex*100))
    pause(300*rand);
        
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    parpool(22);
    
    rng('default')
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));

                    %TrainInstancesCount = 1000;
                    %TrainClassLabels = DS.TrainClassLabels(1:1000);
                    
                    TrainInstancesCount = DS.TrainInstancesCount;
                    TrainClassLabels = DS.TrainClassLabels;

                    Thebestgamma1FINAL = 0;
                    Thebestcost1FINAL = 0;
                    Thebestacc1FINAL = 0;
                    Thebestiming1FINAL = 0;
                    ThebestWarpFINAL = 0;
                    
                    % optimize additional parameters. For now turned off
                    for WarpValue = 0:0
                        
                        [Thebestgamma1,Thebestcost1,Thebestacc1,Thebestiming1] = GridSearchSVM1(-10,0.1,20,TrainInstancesCount,TrainClassLabels,Datasets,i,WarpValue);
                        if Thebestacc1>Thebestacc1FINAL
                            Thebestacc1FINAL = Thebestacc1;
                            Thebestgamma1FINAL = Thebestgamma1;
                            Thebestcost1FINAL = Thebestcost1;
                            ThebestWarpFINAL = WarpValue;
                            Thebestiming1FINAL = Thebestiming1FINAL+Thebestiming1;
                        end
                    end
                    
                    [Thebestgamma2,Thebestcost2,Thebestacc2,Thebestiming2] = GridSearchSVM2(Thebestcost1FINAL-2,0.01,Thebestcost1FINAL+2,TrainInstancesCount,TrainClassLabels,Datasets,i,Thebestgamma1FINAL,ThebestWarpFINAL);

                    [Thebestgamma3,Thebestcost3,Thebestacc3,Thebestiming3] = GridSearchSVM2(Thebestcost2-0.2,0.001,Thebestcost2+0.2,TrainInstancesCount,TrainClassLabels,Datasets,i,Thebestgamma1FINAL,ThebestWarpFINAL);

                    KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(Thebestgamma3),'.kernelmatrix') );
                    
                    KMTrain = KM(1:DS.TrainInstancesCount,1:DS.TrainInstancesCount);
                      
                    tic;
                    cmd = ['-q -m 500 -t 4 -e 0.001 -c ', num2str(2^Thebestcost3)];
                    model_precomputed = svmtrain(DS.TrainClassLabels, [(1:DS.TrainInstancesCount)', KMTrain], cmd);
                    
                    ModelTrainingRuntime = toc;
                    
                    KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(Thebestgamma3),'.kernelmatrix') );
                    
                    KMTESTTOTRAIN = KM(DS.TrainInstancesCount+1:end,1:DS.TrainInstancesCount);
                   
                    tic;
                    %[predict_label_P, accuracy_P, dec_values_P] = svmpredict(DS.TestClassLabels, [(1:DS.TestInstancesCount)', KM(DS.TrainInstancesCount+1:end,1:DS.TrainInstancesCount)], model_precomputed);
                    [predict_label_P, accuracy_P, dec_values_P] = svmpredict(DS.TestClassLabels, [(1:DS.TestInstancesCount)', KMTESTTOTRAIN], model_precomputed);
                    %[predict_label_P, accuracy_P, dec_values_P] = svmpredict(DS.TestClassLabels(1:1000), [(1:1000)', KMTESTTOTRAIN], model_precomputed);
                   
                    PredictionRuntime = toc;
                    
                    Results(i,1) = ThebestWarpFINAL;
                    Results(i,2) = Thebestgamma1FINAL;
                    Results(i,3) = Thebestgamma2;
                    Results(i,4) = Thebestgamma3;
                    
                    Results(i,5) = Thebestcost1FINAL;
                    Results(i,6) = Thebestcost2;
                    Results(i,7) = Thebestcost3;
                    
                    Results(i,8) = Thebestacc1FINAL*0.01;
                    Results(i,9) = Thebestacc2*0.01;
                    Results(i,10) = Thebestacc3*0.01;

                    Results(i,11) = Thebestiming1FINAL+Thebestiming2+Thebestiming3;
                    
                    Results(i,12) = accuracy_P(1)*0.01;
                    Results(i,13) = ModelTrainingRuntime;
                    Results(i,14) = PredictionRuntime;
                    

            end
            dlmwrite( strcat('RunSVMClassifierSINK/','RunSVMClassifierSINK_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex)), Results, 'delimiter', '\t');
   
            
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
end

function [Thebestgamma,Thebestcost,Thebestacc,Thebestiming] = GridSearchSVM1(GridStart,GridStep,GridEnd,TrainInstancesCount,TrainClassLabels,Datasets,DatasetsNumber,WarpValue)


                    previousMaxbestacc = 0;
                    
                    Thebestgamma = 0;
                    Thebestcost = 0;
                    Thebestacc = 0;
                    Thebestiming = 0;

                    % Tuning Parameters
                    for gamma=1:20                     

                    gamma
                    log2cTmp = GridStart:GridStep:GridEnd; 

                    bestacc = zeros(1,length(log2cTmp));
                    bestgamma = zeros(1,length(log2cTmp));
                    bestcost = zeros(1,length(log2cTmp));
                    besttiming = zeros(1,length(log2cTmp));
                    
                      KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(DatasetsNumber)),'/', char(Datasets(DatasetsNumber)), '_SINK_Gamma_', num2str(gamma),'.kernelmatrix') );
                  
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



end

function [Thebestgamma,Thebestcost,Thebestacc,Thebestiming] = GridSearchSVM2(GridStart,GridStep,GridEnd,TrainInstancesCount,TrainClassLabels,Datasets,DatasetsNumber,gamma,WarpValue)


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
                    
                      KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(DatasetsNumber)),'/', char(Datasets(DatasetsNumber)), '_SINK_Gamma_', num2str(gamma),'.kernelmatrix') );
                                      
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

