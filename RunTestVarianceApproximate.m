function RunTestVarianceApproximate(DataSetStartIndex, DataSetEndIndex, RepStartIndex, RepEndIndex, Method)  
    
    Methods = [cellstr('Random'), 'KShape'];

    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                             
    % Sort Datasets
    [Datasets, DSOrder] = sort(Datasets);    
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    for rep = 1 : 10
                        
                        rep
                        rng(rep);
                        
                        if (rep>=RepStartIndex && rep<=RepEndIndex)

                                if Method==1
                                    Dictionary = dlmread( strcat( 'DICTIONARIESRANDOM/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary') );
                                elseif Method==2
                                    Dictionary = dlmread( strcat( 'DICTIONARIESKSHAPE/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary') );
                                end
                                
                                tic;
                                TestVarianceResults = TestVarianceApproximate(Dictionary);
                                RunTime = toc;
                                
                                % GammaForMaxVarByVarExplained20
                                gamma = TestVarianceResults(8);
    
                                Results = [gamma,RunTime];
                                
                                dlmwrite( strcat( 'RunTestVarianceApproximate/', 'RESULTS_RunTestVarianceApproximate_', char(Datasets(i)), '_', char(Methods(Method)), '_',num2str(rep) ,'.Results'), Results, 'delimiter', '\t');      
                                dlmwrite( strcat( 'RunTestVarianceApproximate/', 'RESULTS_RunTestVarianceApproximate_', char(Datasets(i)), '_', char(Methods(Method)), '_',num2str(rep) ,'.TestVarianceResults'), TestVarianceResults, 'delimiter', '\t');      
                            
                            
                            
                        end
                        
                    end
            end
            
            
    end
    
    
end