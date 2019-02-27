function acc = OneNNClassifierFFTED(DS,coeff)
    
    acc = 0;
    
    for id = 1 : DS.TestInstancesCount
        
        classify_this = DS.Test(id,:);
        FFTclassify_this = fft(classify_this)/sqrt(length(classify_this));
        
        FFTclassify_this = dftEnergy(FFTclassify_this, coeff);
        
        best_so_far = inf;

        for i = 1 : DS.TrainInstancesCount
            
            compare_to_this = DS.Train(i,:);
            FFTcompare_to_this = fft(compare_to_this)/sqrt(length(compare_to_this));

            
            FFTcompare_to_this = dftEnergy(FFTcompare_to_this, coeff);;
            
            %distance = sqrt(sum(abs(FFTclassify_this(1:coeff) - FFTcompare_to_this(1:coeff)).^2));
            distance = sqrt(sum(abs(FFTclassify_this - FFTcompare_to_this).^2));

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


function X = dftEnergy(X, k)
% Determine number of fourier coefficients to capture frac of energy
%X = fft(zscore(x))/length(x);          % fft of normalized
Y = abs(X).^2;
%sum(Y)
[Ysorted Yorder] = sort(-Y);           % sort descending
%Ysorted = cumsum(-Ysorted)/sum(Y);
%k = find(Ysorted >= frac, 1);
X(Yorder((k+1):end)) = 0;
%if (~length(k)) k = length(x); end;
%sum(abs(X).^2)
%k = ceil(k/2);   % k <= m/2 unique fourier coefficients of real x
end
