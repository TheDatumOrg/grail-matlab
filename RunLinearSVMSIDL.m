function RunLinearSVMSIDL(DataSetStartIndex, DataSetEndIndex)  
   
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);    

    Results = zeros(length(Datasets),11);
    
    addpath(genpath('LibLinear/matlab/.'));
    
    distcomp.feature( 'LocalUseMpiexec', false )
    
    %rng(ceil(DataSetStartIndex*100))
    %pause(300*rand);
        
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    parpool(22);
    
    rng('default')
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));

                    [Thebestgamma,Thebestcost1,Thebestacc1,Thebestiming1] = GridSearchLinearSVM1(-10,1,20,DS.TrainInstancesCount,DS.TrainClassLabels,Datasets,i,Methods, Method, Types, RepType);
                    [Thebestcost2,Thebestacc2,Thebestiming2] = GridSearchLinearSVM2(-10,0.1,20,DS.TrainInstancesCount,DS.TrainClassLabels,Datasets,i,Methods, Method, Types, RepType,Thebestgamma);

                    if Thebestgamma==1
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif Thebestgamma==2
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif Thebestgamma==3
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.5) ,'.Zrep')  );
                    elseif Thebestgamma==4
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif Thebestgamma==5
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif Thebestgamma==6
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.5) ,'.Zrep')  );
                    elseif Thebestgamma==7
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif Thebestgamma==8
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif Thebestgamma==9
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.5) ,'.Zrep')  );
                    end
                    
                    
                    
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
                    
                    Results(i,1) = Thebestgamma;
                    
                    Results(i,2) = Thebestcost1;
                    Results(i,3) = Thebestcost2;
                    %Results(i,4) = Thebestcost3;
                    Results(i,4) = 0;
                    
                    Results(i,5) = Thebestacc1*0.01;
                    Results(i,6) = Thebestacc2*0.01;
                    %Results(i,7) = Thebestacc3*0.01;
                    Results(i,7) = 0;

                    %Results(i,8) = Thebestiming1+Thebestiming2+Thebestiming3;
                    Results(i,8) = Thebestiming1+Thebestiming2;
                    
                    Results(i,9) = accuracy_P(1)*0.01;
                    Results(i,10) = ModelTrainingRuntime;
                    Results(i,11) = PredictionRuntime;
                
                    dlmwrite( strcat('RunLinearSVMSIDL/','RunLinearSVMSIDL', '_Dataset_', num2str(i)) , Results, 'delimiter', '\t');
           

            end
            
            
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
end

function [Thebestgamma,Thebestcost,Thebestacc,Thebestiming] = GridSearchLinearSVM1(GridStart,GridStep,GridEnd,TrainInstancesCount,TrainClassLabels,Datasets,DatasetsNumber)

                    

                    previousMaxbestacc = 0;
                    
                    Thebestgamma = 0;
                    Thebestcost = 0;
                    Thebestacc = 0;
                    Thebestiming = 0;

                    
                    % Tuning Parameters
                    for gamma=1:9                     

                    gamma
                    
                    log2cTmp = GridStart:GridStep:GridEnd; 

                    bestacc = zeros(1,length(log2cTmp));
                    bestgamma = zeros(1,length(log2cTmp));
                    bestcost = zeros(1,length(log2cTmp));
                    besttiming = zeros(1,length(log2cTmp));
                    

                    if gamma==1
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif gamma==2
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif gamma==3
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.5) ,'.Zrep')  );
                    elseif gamma==4
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif gamma==5
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif gamma==6
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.5) ,'.Zrep')  );
                    elseif gamma==7
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif gamma==8
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif gamma==9
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.5) ,'.Zrep')  );
                    end
                    
                    
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



function [Thebestcost,Thebestacc,Thebestiming] = GridSearchLinearSVM2(GridStart,GridStep,GridEnd,TrainInstancesCount,TrainClassLabels,Datasets,DatasetsNumber,Thebestgamma)

                    rep=1;

                    % Tuning Parameters

                    log2cTmp = GridStart:GridStep:GridEnd; 

                    bestacc = zeros(1,length(log2cTmp));
                    bestcost = zeros(1,length(log2cTmp));
                    besttiming = zeros(1,length(log2cTmp));
                    
                    if Thebestgamma==1
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif Thebestgamma==2
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif Thebestgamma==3
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(0.1), '_R_', num2str(0.5) ,'.Zrep')  );
                    elseif Thebestgamma==4
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif Thebestgamma==5
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif Thebestgamma==6
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(1), '_R_', num2str(0.5) ,'.Zrep')  );
                    elseif Thebestgamma==7
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.1) ,'.Zrep')  );
                    elseif Thebestgamma==8
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.25) ,'.Zrep')  );
                    elseif Thebestgamma==9
                        ZRep = dlmread( strcat( 'SIDLREPRESENTATIONS','/',char(Datasets(DatasetsNumber)),'/','SIDLREPRESENTATIONS', '_L_', num2str(10), '_R_', num2str(0.5) ,'.Zrep')  );
                    end
                    
                    
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

