function RunLOOCandOneNNDTW(DataSetStartIndex, DataSetEndIndex)  
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/UCR2018/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);

    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    LeaveOneOutAccuracies = zeros(length(Datasets),20);
                    LeaveOneOutRuntimes = zeros(length(Datasets),20);
    
                    Results = zeros(length(Datasets),6);
                
                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    TSLength = length(DS.Data(1,:));
                    
                    for gamma=1:20

                        gammaTmp = gamma-1
                        window = floor(gammaTmp/100 * TSLength); 
                        tic;
                        acc = LOOClassifierDTW(DS,window);
                        LeaveOneOutRuntimes(i,gamma) = toc;
                        LeaveOneOutAccuracies(i,gamma) = acc;
                    end

                    [MaxLeaveOneOutAcc,MaxLeaveOneOutAccGamma] = max(LeaveOneOutAccuracies(i,:));
                    
                    tic;
                    window = floor((MaxLeaveOneOutAccGamma-1)/100 * TSLength); 
                    OneNNAcc = OneNNClassifierDTW(DS,window);
                    
                    Results(i,1) = MaxLeaveOneOutAccGamma-1;
                    Results(i,2) = MaxLeaveOneOutAcc;
                    Results(i,3) = LeaveOneOutRuntimes(i,MaxLeaveOneOutAccGamma);
                    Results(i,4) = sum(LeaveOneOutRuntimes(i,:));
                    Results(i,5) = OneNNAcc;
                    Results(i,6) = toc;
   
                    dlmwrite( strcat('/rigel/dsi/users/ikp2103/JOPA/GRAIL2/RunLOOCandOneNNDTW/', 'RunLOOCandOneNNDTW_Dataset_', num2str(i)),  Results, 'delimiter', '\t');
   
            end
            
            
    end
    
end