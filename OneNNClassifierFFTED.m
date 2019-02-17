function acc = OneNNClassifierFFTED(DS,coeff)
    
    acc = 0;
    
    for id = 1 : DS.TestInstancesCount
        
        classify_this = DS.Test(id,:);
        FFTclassify_this = fft(classify_this)/sqrt(length(classify_this));
        
        best_so_far = inf;

        for i = 1 : DS.TrainInstancesCount
            
            compare_to_this = DS.Train(i,:);
            FFTcompare_to_this = fft(compare_to_this)/sqrt(length(compare_to_this));

            distance = sqrt(sum(abs(FFTclassify_this(1:coeff) - FFTcompare_to_this(1:coeff)).^2));

            if distance < best_so_far
                class = DS.TrainClassLabels(i);
                best_so_far = distance;
            end
        end
        
        if (DS.TestClassLabels(id) == class)
            acc = acc + 1;
        end
    end
    
    acc = acc / DS.TestInstancesCount;
end
