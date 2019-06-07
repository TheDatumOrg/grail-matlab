function RunLinearSVMSPIRAL(DataSetStartIndex, DataSetEndIndex)  
 
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);    

    Results = zeros(length(Datasets),11);
    
    addpath(genpath('LibLinear/matlab/.'));
    
    distcomp.feature( 'LocalUseMpiexec', false )
    
    rng(ceil(DataSetStartIndex*100))
    pause(100*rand);
        
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    parpool(22);
    
    rng('default')
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));

                    
                    [Thebestcost2,Thebestacc2,Thebestiming2] = GridSearchLinearSVM2(-10,0.1,20,DS.TrainInstancesCount,DS.TrainClassLabels,Datasets,i);
                    
                    
                    ZRep = dlmread( strcat( 'SPIRALREPRESENTATIONS','/',char(Datasets(i)),'/','SIDLREPRESENTATIONS', '.Zrep')  );
                    
                    ZRepTrain = ZRep(1:DS.TrainInstancesCount,:);
                    ZRepTest = ZRep(DS.TrainInstancesCount+1:end,:);
                    
                    ZRepTrain = sparse(ZRepTrain);
                    ZRepTest = sparse(ZRepTest);
                      
                    tic;
                    cmd = ['-e 0.001 -s 2 -c ', num2str(2^Thebestcost2)];
                    model_precomputed = train(DS.TrainClassLabels, ZRepTrain, cmd);
                    
                    ModelTrainingRuntime = toc;
                    
                    tic;
                    
                    [predict_label_P, accuracy_P, dec_values_P] = predict(DS.TestClassLabels, ZRepTest, model_precomputed);
                    
                    PredictionRuntime = toc;
                    
                    Results(i,1) = 0;
                    
                    Results(i,2) = 0;
                    Results(i,3) = Thebestcost2;
                    %Results(i,4) = Thebestcost3;
                    Results(i,4) = 0;
                    
                    Results(i,5) = 0;
                    Results(i,6) = Thebestacc2*0.01;
                    %Results(i,7) = Thebestacc3*0.01;
                    Results(i,7) = 0;

                    %Results(i,8) = Thebestiming1+Thebestiming2+Thebestiming3;
                    Results(i,8) = Thebestiming2;
                    
                    Results(i,9) = accuracy_P(1)*0.01;
                    Results(i,10) = ModelTrainingRuntime;
                    Results(i,11) = PredictionRuntime;
                
                    dlmwrite( strcat('RunLinearSVMRWS/','RunLinearSVMRWS', '_Dataset_', num2str(i)) , Results, 'delimiter', '\t');
           

            end
            
            
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
end

function [Thebestcost,Thebestacc,Thebestiming] = GridSearchLinearSVM2(GridStart,GridStep,GridEnd,TrainInstancesCount,TrainClassLabels,Datasets,DatasetsNumber)

                    
                    % Tuning Parameters

                    log2cTmp = GridStart:GridStep:GridEnd; 

                    bestacc = zeros(1,length(log2cTmp));
                    bestcost = zeros(1,length(log2cTmp));
                    besttiming = zeros(1,length(log2cTmp));
                    
                    ZRep = dlmread( strcat( 'SPIRALREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '.Zrep')  );
                    
                    ZRepTrain = ZRep(1:TrainInstancesCount,:);
                    ZRepTrain = sparse(ZRepTrain);
                      
                      % grid search
                      parfor log2cNEW = 1:length(log2cTmp)
                        
                        log2cNEW
                        tic;
                        log2c = log2cTmp(log2cNEW);
                        cmd = ['-q -e 0.001 -s 2 -v ' num2str(10) ' -c ', num2str(2^log2c)];
                        cv = train(TrainClassLabels, ZRepTrain, cmd);
                          
                        bestacc(log2cNEW) = cv;
                        bestcost(log2cNEW) = log2c; 
                        besttiming(log2cNEW) = toc;

                      end


                    [Maxbestacc,~] = max(bestacc);
                    Posbestacc = find(bestacc==Maxbestacc,1,'last');
                    
                    Thebestiming = sum(besttiming);
                    Thebestcost = bestcost(Posbestacc);
                    Thebestacc = Maxbestacc;


end

