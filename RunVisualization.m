function RunVisualization(DataSetStartIndex, DataSetEndIndex, Method, RepType)  
    
    Methods = [cellstr('Random'), 'KShape'];
    Types = [cellstr('ZExact'), 'Z5', 'Z10', 'Z20', 'Z99per', 'Z95per', 'Z90per', 'Z85per', 'Z80per'];

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);    
	
    Results = zeros(length(Datasets),3);
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex & i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    % Get Kernel Matrix
                    
                    gamma = 10;
                    
                    KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(gamma) ,'.kernelmatrix') );
                    
                    tic;
                    [EigenVectors,ProjDataOriginal] = OriginalKPCA(KM);
                    RTOriginalKPCA = toc;
                    
                    
                    for rep = 1 : 10
                        rep
                        rng(rep);
                        
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
                        if RepType == 1
                            [ApproxEigVectors,ProjDataApprox] = NystromKPCA(ZExact);
                        elseif RepType == 2
                            [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z5);
                        elseif RepType == 3
                            [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z10);
                        elseif RepType == 4
                            [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z20);
                        elseif RepType == 5
                                [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z98per);
                        elseif RepType == 6
                                [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z95per);
                        elseif RepType == 7
                                [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z90per);
                        elseif RepType == 8
                                [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z85per);
                        elseif RepType == 9    
                                [ApproxEigVectors,ProjDataApprox] = NystromKPCA(Z80per);
                        end

                        RTApproximatelKPCA = toc;
                        
                        dlmwrite( strcat( 'RunVisualizationVectors/','RESULTS_RunVisualization_', num2str(i), '_', num2str(i), '_', char(Methods(Method)), '_', char(Types(RepType)) ,'.Vectors'), ApproxEigVectors, 'delimiter', '\t');
   
                        % Evaluate SmplPoints in terms of clustering
                        % measures (e.g., SSE, RandIndex, NystromAppx)
                        
                        %Error = Arccos dot(u,v)/(norm(u)*norm(v))
                        %AppxError = acos(dot(EigenVectors(:,1),ApproxEigVectors(:,1))/(norm(EigenVectors(:,1))*norm(ApproxEigVectors(:,1))));
                        AppxError = ( norm(ProjDataOriginal*ProjDataOriginal'-ProjDataApprox*ProjDataApprox','fro') );
                        
                        ResultsTmp = [AppxError,RTApproximatelKPCA,RTOriginalKPCA];
                           
                        %
                        Results(i,:) = Results(i,:) + ResultsTmp;
                    end
                    Results(i,:) = Results(i,:) ./ 10;
           
            end
            
            dlmwrite( strcat( 'RunVisualization/','RESULTS_RunVisualization_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex), '_', char(Methods(Method)), '_', char(Types(RepType)) ,'.results'), Results, 'delimiter', '\t');
   
    end
    
end