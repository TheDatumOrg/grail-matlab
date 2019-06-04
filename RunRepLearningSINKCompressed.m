function RunRepLearningSINKCompressed(DataSetStartIndex, DataSetEndIndex, Method, gamma)  
    
    Methods = [cellstr('Random'), 'KShape'];
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/VLDBGRAIL/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);  
    
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    display(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    for rep = 1 : 1
                        
                        rep
                        rng(rep);
                        
                        %if (rep>=RepStartIndex & rep<=RepEndIndex)
                        
                            %for gamma = 1 : 20

                                gamma
                
                                if Method==1
                                    Dictionary = dlmread( strcat( 'DICTIONARIESRANDOM/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary') );
                                elseif Method==2
                                    Dictionary = dlmread( strcat( 'DICTIONARIESKSHAPE/',char(Datasets(i)),'/','RunDLFixedSamples', '_', char(Methods(Method)), '_', num2str(rep) ,'.Dictionary') );
                                end
                                
                                DSFourier = DatasetToFourier(DS, 0.99, 100);
                                
                                [Zexact, Ztop5, Ztop10, Ztop20, Z99per, Z98per, Z97per, Z95per, Z90per, Z85per, Z80per, DistComp, RuntimeNystrom, RuntimeFD]=RepLearnFINALSINKComp(DS.Data, Dictionary, gamma, DSFourier.NumCoeffs);

                                Results = [DistComp, RuntimeNystrom, RuntimeFD];
                                
                                %myflag = true;
                                %count=0;
                                %while(myflag)
                                
                                    
                                    %try
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Zexact'), Zexact, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop5'), Ztop5, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop10'), Ztop10, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Ztop20'), Ztop20, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z99per'), Z99per, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z98per'), Z98per, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z97per'), Z97per, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z95per'), Z95per, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z90per'), Z90per, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z85per'), Z85per, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RepLearningFixedSamplesSINKComp', '_', char(Methods(Method)), '_', num2str(rep) ,'.Z80per'), Z80per, 'delimiter', '\t');
                                    pause(5);
                                    dlmwrite( strcat( 'REPRESENTATIONSGamma', num2str(gamma),'/',char(Datasets(i)),'/','RESULTS_RepLearningFixedSamplesSINKComp_', char(Methods(Method)), '_',num2str(rep) ,'.Results'), Results, 'delimiter', '\t');      
                                    %myflag = false;
                                    %%%%%%%%fclose('all') ;
                                    %catch
                                    %    disp('attempt to write failed - trying again');
                                    %    pause(30+rep+gamma)
                                        
                                    %end
                                    %count=count+1;
                                    %if count==5
                                    %    disp('5 attempts! - I quit!');
                                    %    break;
                                    %end
                                    
                                %end   

                            %end
                            
                            
                            
                            
                            
                        %end
                        
                    end
            end
            
            
    end
    
    
end
