function RunDictLearning(DataSetStartIndex, DataSetEndIndex, Method, RepStartIndex, RepEndIndex)  
    
    Methods = [cellstr('Random'), 'KShape', 'GibbsDPP'];
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets); 
    
    for i = 1:length(Datasets)
        if (i>=DataSetStartIndex & i<=DataSetEndIndex)

            disp(['Dataset being processed: ', char(Datasets(i))]);
            DS = LoadUCRdataset(char(Datasets(i)));
            
            for rep = 1 : 10
                
                if (rep>=RepStartIndex & rep<=RepEndIndex)
                        
                    rep
                    rng(rep);
                    
                    NumOfSamples = min(max( [4*length(DS.ClassNames), ceil(0.4*DS.DataInstancesCount),30] ),200);
                        
                        
                        if Method==1
                            tic;
                            permed_index = randperm(DS.DataInstancesCount);
                            Dictionary = DS.Data(permed_index(1:NumOfSamples),:);
                            timing = toc;
                        elseif Method==2
                            sumdtmp=Inf;
                            for Repetion=1:3
                            
                                %tic;
                                [mem,Dictionary,iter,sumd,centKpp,centKppSmplPoints,DistValues,DistShifts,DistComp,RuntimekShape,DistCompSeed,RuntimeSeed] = kShapeCentroids(DS.Data, NumOfSamples, 1);
                                %timing = toc;
                                
                                if sumd<sumdtmp
                                   BestDictionary = Dictionary; 
                                   BestcentKpp = centKpp;
                                   BestcentKppSmplPoints = centKppSmplPoints;
                                   BesttimingKShape = RuntimekShape;
                                   BestDistComp = DistComp;
                                   BestDistCompSeed = DistCompSeed;
                                   BesttimingSeed = RuntimeSeed;
                                   sumdtmp = sumd;
                                end
                                
                            end
                            
                        elseif Method==3
                                KM = dlmread( strcat( 'DistanceMatrices/',char(Datasets(i)),'/', char(Datasets(i)), '_SBD.distmatrix'));
                                KM = DM2KM(KM);
                                tic;
                                [SmplPoints,DistComp] = GibbsDPP(KM, 1000, NumOfSamples);
                                Dictionary = DS.Data(SmplPoints,:);
                                BestDistComp = DistComp;
                                timing = toc;

                        end
                        

                            if Method==1
                                Centroids = Dictionary;
                                ClustRuntime = timing;
                            elseif Method==2 
                                Centroids = BestDictionary;
                                KppCentroids = BestcentKpp;
                                KppSmplPoints = BestcentKppSmplPoints;
                                ClustRuntime = BesttimingKShape;
                                DistComputation = BestDistComp;
                                DistComputationSeed = BestDistCompSeed;
                                SeedRuntime = BesttimingSeed;
                            elseif Method==3
                                Centroids = Dictionary;
                                ClustRuntime = timing;  
                                DistComputation = BestDistComp;
                            end

                    
                    if Method==1
                        dlmwrite( strcat( 'DICTIONARIESRANDOM/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary'), Centroids, 'delimiter', '\t');
                        dlmwrite( strcat( 'RunDictLearning/','RunDLFixedSamples', '_', char(Methods(Method)),'_', num2str(i), '_', num2str(rep) ,'.Statistics'), ClustRuntime, 'delimiter', '\t');
                     elseif Method==2
                        dlmwrite( strcat( 'DICTIONARIESKSHAPE/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary'), Centroids, 'delimiter', '\t');
                        dlmwrite( strcat( 'DICTIONARIESKSHAPE/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.KppCentroids'), KppCentroids, 'delimiter', '\t');
                        dlmwrite( strcat( 'DICTIONARIESKSHAPE/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.KppSmplPoints'), KppSmplPoints, 'delimiter', '\t');
                        dlmwrite( strcat( 'RunDictLearning/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(i) ,'_', num2str(rep) ,'.Statistics'), [ClustRuntime,SeedRuntime,DistComputation,DistComputationSeed], 'delimiter', '\t');
                    elseif Method==3
                        dlmwrite( strcat( 'DICTIONARIESGIBBSDPP/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary'), Centroids, 'delimiter', '\t');
                        dlmwrite( strcat( 'RunDictLearning/','RunDLFixedSamples', '_', char(Methods(Method)),'_', num2str(i), '_', num2str(rep) ,'.Statistics'), [ClustRuntime,DistComputation], 'delimiter', '\t');
                    end
                    
                    
                    
                end
            end

       end
            
    end
    
end