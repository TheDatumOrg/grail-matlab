function RunClassificationOneNN(DataSetStartIndex, DataSetEndIndex, ClassificationMethod, Method, RepType, LBType)  
    
    ClassMethods = [cellstr('OneNN'), 'OneNNLB'];
    Methods = [cellstr('Random'), 'KShape'];
    Types = [cellstr('ZExact'), 'Z5', 'Z10', 'Z20', 'Z98per', 'Z95per', 'Z90per', 'Z85per', 'Z80per'];
    LBTypes = [cellstr('FFTtopk'), 'FFTbestk', 'RepLearn', 'LBKeogh'];
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);    
	
    Results = zeros(length(Datasets),3);
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    % Get Kernel Matrix
                    %KM = dlmread( strcat( 'DATASETS/',char(Datasets(i)),'/', char(Datasets(i)), '_CCKernel_', num2str(gamma) ,'.kernelmatrix'));
                  
                    %KM = dlmread( strcat( 'DATASETS/',char(Datasets(i)),'/', char(Datasets(i)), '_NCCc', '.distmatrix'));
                    
                    %KM = DM2Kernel(KM);
                    
                    DS.DTW_WindowPercentage = round(5/100*length(DS.Data(1,:)));
                    
                    for rep = 1 : 1
                        rep
                        rng(rep);
                        
                        % Extract Sample Points

                        TestVarianceNew = dlmread( strcat( 'RunTestVarianceApproximate/', 'RESULTS_RunTestVarianceApproximate_', char(Datasets(i)), '_', char(Methods(Method)), '_',num2str(rep) ,'.Results'));      
                        
                        gamma = TestVarianceNew(1);
                        %gamma = 5;
                        
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

                        
                        tic;
                        if ClassificationMethod == 1
                            pruningpower=0;
                            if RepType == 1
                                acc = OneNNClassifierZREP(DS,ZExact);
                            elseif RepType == 2
                                acc = OneNNClassifierZREP(DS,Z5);
                            elseif RepType == 3
                                acc = OneNNClassifierZREP(DS,Z10);
                            elseif RepType == 4
                                acc = OneNNClassifierZREP(DS,Z20);
                            elseif RepType == 5
                                acc = OneNNClassifierZREP(DS,Z98per);
                            elseif RepType == 6
                                acc = OneNNClassifierZREP(DS,Z95per);
                            elseif RepType == 7
                                acc = OneNNClassifierZREP(DS,Z90per);
                            elseif RepType == 8
                                acc = OneNNClassifierZREP(DS,Z85per);
                            elseif RepType == 9    
                                acc = OneNNClassifierZREP(DS,Z80per);
                            end
                        elseif ClassificationMethod == 2
                            if RepType == 1
                                [acc,pruningpower] = OneNNClassifierLB(DS,ZExact,LBType,gamma);
                                
                            elseif RepType == 2
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z5,LBType,gamma);
                            elseif RepType == 3
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z10,LBType,gamma);
                            elseif RepType == 4
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z20,LBType,gamma);
                            elseif RepType == 5
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z98per,LBType,gamma);
                            elseif RepType == 6
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z95per,LBType,gamma);
                            elseif RepType == 7
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z90per,LBType,gamma);
                            elseif RepType == 8
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z85per,LBType,gamma);
                            elseif RepType == 9    
                                [acc,pruningpower] = OneNNClassifierLB(DS,Z80per,LBType,gamma);
                            end
                        end
                        
                        ClassificationTime = toc;

                        % Evaluate SmplPoints in terms of clustering
                        % measures (e.g., SSE, RandIndex, NystromAppx)
                        
                        ResultsTmp = [acc,pruningpower,ClassificationTime];
                           
                        %
                        Results(i,:) = Results(i,:) + ResultsTmp;
                    end
                    Results(i,:) = Results(i,:) ./ 1;
           
            end
            
            dlmwrite( strcat( 'RunClassificationOneNN/','RESULTS_RunClassificationOneNN_', char(ClassMethods(ClassificationMethod)), '_', char(Methods(Method)), '_', char(Types(RepType)), '_', char(LBTypes(LBType)), '_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex),'.results'), Results, 'delimiter', '\t');
   
    end
    
end