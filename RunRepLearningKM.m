function RunRepLearningKM(DataSetStartIndex, DataSetEndIndex, GammaStartIndex, GammaEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);   
   
    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    Results = zeros(length(Datasets),20);
                    
                    for gamma = 1 : 20
                        
                        if (gamma>=GammaStartIndex && gamma<=GammaEndIndex)
                    
                            gamma 
                            
                            KM = dlmread( strcat( 'KernelMatricesSINK/',char(Datasets(i)),'/', char(Datasets(i)), '_SINK_Gamma_', num2str(gamma) ,'.kernelmatrix'));

                            [Z99per,Z98per,Z97per,Z95per,Z90per,Z85per,Z80per,Ztop20,Ztop10,Ztop5,RepLearnTime]=RepLearnKM(KM);

                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z99per'), Z99per, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z98per'), Z98per, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z97per'), Z97per, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z95per'), Z95per, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z90per'), Z90per, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z85per'), Z85per, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z80per'), Z80per, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z20'), Ztop20, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z10'), Ztop10, 'delimiter', '\t');
                            dlmwrite( strcat( 'REPRESENTATIONSFULLKM/',char(Datasets(i)),'/','RepresentationFULLKM_', num2str(gamma) ,'.Z5'), Ztop5, 'delimiter', '\t');

                            Results(i,gamma)=RepLearnTime;
                            
                            dlmwrite( strcat('RunRepLearningKM/','RunRepLearningKM_Gamma_', num2str(gamma), '_Dataset_', num2str(i)), Results, 'delimiter', '\t');
                    
                            
                        end
                        
                    end
                    
                    
                    
            end
            
    end
    
end
