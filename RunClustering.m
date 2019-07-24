function RunClustering(DataSetStartIndex, DataSetEndIndex, ClusteringMethod, Method, RepType)  
    
    Methods = [cellstr('Random'), 'KShape'];
    Types = [cellstr('ZExact'), 'Z5', 'Z10', 'Z20', 'Z98per', 'Z95per', 'Z90per', 'Z85per', 'Z80per'];

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);    
	
    Results = zeros(length(Datasets),2);
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex & i<=DataSetEndIndex)

                    display(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    % Get Kernel Matrix
                    %KM = dlmread( strcat( 'DATASETS/',char(Datasets(i)),'/', char(Datasets(i)), '_CCKernel_', num2str(gamma) ,'.kernelmatrix'));
                  
                    %KM = dlmread( strcat( 'DATASETS/',char(Datasets(i)),'/', char(Datasets(i)), '_NCCc', '.distmatrix'));
                    
                    %KM = DM2Kernel(KM);
                    
                    for rep = 1 : 1
                        rep
                        rng(rep);
                        
                        % Find appropriate gamma for this rep for this
                        % dataset
                        TestVarianceNew = dlmread( strcat( 'RunTestVarianceApproximate/', 'RESULTS_RunTestVarianceApproximate_', char(Datasets(i)), '_', char(Methods(Method)), '_',num2str(rep) ,'.Results'));      
                        
                        gamma = TestVarianceNew(1);
                        
                        % Extract Sample Points

                        ZExact = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Zexact')  );
                        
                        Z5 = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop5')  );
                        Z10 = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop10')  );
                        Z20 = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop20')  );

                        Z98per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z98per')  );
                        Z95per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z95per')  );
                        Z90per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z90per')  );
                        Z85per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z85per')  );
                        Z80per = dlmread( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z80per')  );                 

                        %ZResults = dlmread( strcat( 'APPROXREPRESENTATIONS100/',char(Datasets(i)),'/','RepLearningTuned', '_', char(Methods(Method)), '_', num2str(rep) ,'.Results'));  

                        tic;
                        if ClusteringMethod == 1
                            if RepType == 1
                                mem = KernelKmeansClustering(ZExact, ZExact, length(DS.ClassNames));
                            elseif RepType == 2
                                mem = KernelKmeansClustering(ZExact, Z5, length(DS.ClassNames));
                            elseif RepType == 3
                                mem = KernelKmeansClustering(ZExact, Z10, length(DS.ClassNames));
                            elseif RepType == 4
                                mem = KernelKmeansClustering(ZExact, Z20, length(DS.ClassNames));
                            elseif RepType == 5
                                mem = KernelKmeansClustering(ZExact, Z98per, length(DS.ClassNames));
                            elseif RepType == 6
                                mem = KernelKmeansClustering(ZExact, Z95per, length(DS.ClassNames));
                            elseif RepType == 7
                                mem = KernelKmeansClustering(ZExact, Z90per, length(DS.ClassNames));
                            elseif RepType == 8
                                mem = KernelKmeansClustering(ZExact, Z85per, length(DS.ClassNames));
                            elseif RepType == 9    
                                mem = KernelKmeansClustering(ZExact, Z80per, length(DS.ClassNames));
                            end
                        elseif ClusteringMethod == 2
                            if RepType == 1
                                mem = KernelSCApprox(ZExact, length(DS.ClassNames));
                            elseif RepType == 2
                                mem = KernelSCApprox(Z5, length(DS.ClassNames));
                            elseif RepType == 3
                                mem = KernelSCApprox(Z10, length(DS.ClassNames));
                            elseif RepType == 4
                                mem = KernelSCApprox(Z20, length(DS.ClassNames));
                            elseif RepType == 5
                                mem = KernelSCApprox(Z98per, length(DS.ClassNames));
                            elseif RepType == 6
                                mem = KernelSCApprox(Z95per, length(DS.ClassNames));
                            elseif RepType == 7
                                mem = KernelSCApprox(Z90per, length(DS.ClassNames));
                            elseif RepType == 8
                                mem = KernelSCApprox(Z85per, length(DS.ClassNames));
                            elseif RepType == 9    
                                mem = KernelSCApprox(Z80per, length(DS.ClassNames));
                            end
                        end
                        
                        ClusteringTime = toc;
                        
                        
                        RI = RandIndex(mem, DS.DataClassLabels);
                        
                        % Evaluate SmplPoints in terms of clustering
                        % measures (e.g., SSE, RandIndex, NystromAppx)
                        
                        ResultsTmp = [RI,ClusteringTime];
                           
                        %
                        Results(i,:) = Results(i,:) + ResultsTmp;
                    end
                    Results(i,:) = Results(i,:) ./ 1;
           
            end
            
            dlmwrite( strcat( 'RunClustering/','RESULTS_RunClustering_', num2str(ClusteringMethod), '_', char(Methods(Method)), '_', char(Types(RepType)), '_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex),'.results'), Results, 'delimiter', '\t');
   
    end
    
end