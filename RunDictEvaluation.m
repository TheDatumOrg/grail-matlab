function RunDictEvaluation(DataSetStartIndex, DataSetEndIndex, Method, gamma)  
        
    Methods = [cellstr('Random'), 'KShape', 'AFKMC2', 'GibbsDPP','SRFT','LevScore','Gaussian'];

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);   
    
    addpath(genpath('NystromBestiary/.'));
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex & i<=DataSetEndIndex)

                    Results = zeros(length(Datasets),4);
                
                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    % Get Kernel Matrix
                    
                    KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(gamma) ,'.kernelmatrix') );
                    
                    NumOfSamples = min(max( [4*length(DS.ClassNames), ceil(0.4*DS.DataInstancesCount),20] ),100);
                    
                    Runtime = 0;
                    for rep = 1 : 10
                        rep
                        rng(rep);
                        
                        if Method==1
                            Dictionary = dlmread( strcat( 'DICTIONARIESRANDOM/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary') );
                        elseif Method==2
                            Dictionary = dlmread( strcat( 'DICTIONARIESKSHAPE/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary') );
                        elseif Method==3
                            Dictionary = dlmread( strcat( 'DICTIONARIESKSHAPE/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char('KShape'), '_', num2str(rep) ,'.KppCentroids') );                            
                        elseif Method==4
                            Dictionary = dlmread( strcat( 'DICTIONARIESGIBBSDPP/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary') );
                        elseif Method==5
                            
                            tic;
                            in.A = KM;
                            in.linearkernelflag = 0;
                            in.k = 5;
                            in.l = NumOfSamples;
                            in.q = 1;
                            out = srft_Nystrom(in);
                            Runtime = Runtime + toc;
                            
                        elseif Method==6
                            
                            tic;
                            in.A = KM;
                            in.linearkernelflag = 0;
                            in.k = 5;
                            in.l = NumOfSamples;
                            in.q = 1;
                            
                            [U, Sigma] = orderedeigs(in.A, in.k+1);
                             U1t = U(:, 1:in.k)';
                             levscores = sum(U1t.*U1t);
                             in.levscorecomputationtime = 0;
                             in.levscoreprobs = levscores/in.k;
                            
                             out = levscore_Nystrom(in);
                             
                             Runtime = Runtime + toc;
                             
                         elseif Method==7
                            
                            tic;
                            in.A = KM;
                            in.linearkernelflag = 0;
                            in.k = 5;
                            in.l = NumOfSamples;
                            in.q = 1;
                            out = gaussian_Nystrom(in);    
                            Runtime = Runtime + toc;
                        end
                        
                        if Method==5
                            [AbsFroError,RelFroError,NormFroError] = NystromMatrixGivenWandE(KM, out.C, out.Winv);
                        elseif Method==6
                            [AbsFroError,RelFroError,NormFroError] = NystromMatrixGivenWandE(KM, out.C, out.Winv);
                        elseif Method==7
                            [AbsFroError,RelFroError,NormFroError] = NystromMatrixGivenWandE(KM, out.C, out.Winv);
                        else
                            [AbsFroError,RelFroError,NormFroError] = NystromMatrixDictionary(KM, DS.Data, Dictionary, gamma);
                        end
                        ResultsTmp = [AbsFroError,RelFroError,NormFroError,Runtime];
                          
                        %
                        Results(i,:) = Results(i,:) + ResultsTmp;
                        %if rep==10
                        %    ResultsRep10 = Results(i,:) ./ 10;
                        %    dlmwrite( strcat( 'EvaluateDictionaries/','RESULTS_EvaluateDictionaries_10Rep_', char(Methods(Method)), '_', num2str(gamma), '_' ,num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex) ,'.results'), ResultsRep10, 'delimiter', '\t');
                        %
                        %end
                    end
                    Results(i,:) = Results(i,:) ./ 10;
                    
                    dlmwrite( strcat( '/rigel/dsi/users/ikp2103/VLDBGRAIL/RunDictEvaluation/','RunDictEvaluation_10Rep_', char(Methods(Method)), '_', num2str(gamma), '_' ,num2str(i) ,'.results'), Results, 'delimiter', '\t');
   
            end
            
            
    end
    
end