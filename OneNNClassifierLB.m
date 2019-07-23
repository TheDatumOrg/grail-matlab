function [acc,pruningpower] = OneNNClassifierLB(DS,ZReduced,LBType,gamma)
    
    % 1 - LB with FFT using the first-k coefficients
    % 2 - LB with FFT using the best-k coefficients
    % 3 - Our approach
    % 4 - LBKeogh for DTW

    ZRepTrain = ZReduced(1:DS.TrainInstancesCount,:);
    ZRepTest = ZReduced(DS.TrainInstancesCount+1:end,:);
    
    Dim = size(ZReduced,2);
    
    acc = 0;
    
    for id = 1 : DS.TestInstancesCount
        
        best_so_far = inf;
        
		distance_lb = zeros(1, DS.TrainInstancesCount);
		
        if LBType==4
            u = upper_b(DS.Test(id,:), DS.DTW_WindowPercentage);
            l = lower_b(DS.Test(id,:), DS.DTW_WindowPercentage);
        end
        
        lbdistcomp = 0;
        for i = 1 : DS.TrainInstancesCount
            switch LBType
                case 1
                    distance_lb(i) = FFTLBTopCoeff(DS.Train(i,:),DS.Test(id,:), Dim);
                case 2
                    distance_lb(i) = FFTLBBestCoeff(DS.Train(i,:),DS.Test(id,:), Dim);
                case 3
                    distance_lb(i) = sqrt(sum((ZRepTrain(i,:)-ZRepTest(id,:)).^2));
                case 4
                    distance_lb(i) = lb_keogh(DS.Train(i,:),DS.Test(id,:), u, l);
            end
            
            
			%distance_lb(i) = lb_keogh(DS.Train(i,:),DS.Test(id,:), u, l);
            %distance_lb(i) = FFTLBBestCoeff(DS.Train(i,:),DS.Test(id,:), size(ZReduced,2));
            %distance_lb(i) = sqrt(sum((ZRepTrain(i,:)-ZRepTest(id,:)).^2));
            
            lbdistcomp=lbdistcomp+1;
        end
        
        [distance_lb, ordering] = sort(distance_lb);
        
		traindata = DS.Train(ordering,:);
        
		trainclasses = DS.TrainClassLabels(ordering);
        
        actualdistcomp = 0;
        
		for i = 1 : DS.TrainInstancesCount
			if distance_lb(i) < best_so_far
				
               switch LBType
                    case 1
                        distance = sqrt(sum((traindata(i,:)-DS.Test(id,:)).^2));
                    case 2
                        distance = sqrt(sum((traindata(i,:)-DS.Test(id,:)).^2));
                    case 3
                        distance = 2*(1-SINK(traindata(i,:),DS.Test(id,:),gamma));
                    case 4
                        distance = dtw(traindata(i,:),DS.Test(id,:),DS.DTW_WindowPercentage);
               end

                actualdistcomp=actualdistcomp+1;

                if distance < best_so_far
                        class = trainclasses(i);
                        best_so_far = distance;
                end
            else
                    break;
            end
            
        end
        
        if (DS.TestClassLabels(id) == class)
            acc = acc + 1;
        end
        
        pruningpower = 1- (actualdistcomp/lbdistcomp);
   end
    acc = acc / DS.TestInstancesCount;
end

function lbdist = FFTLBTopCoeff(x, y, coeff)
    fx = fft(x)/sqrt(length(x));
    fy = fft(y)/sqrt(length(x));
    lbdist = sqrt(sum(abs(fx(1:coeff) - fy(1:coeff)).^2));
end

function lbdist = FFTLBBestCoeff(x, y, coeff)
    fx = fft(x)/sqrt(length(x));    
    fy = fft(y)/sqrt(length(x));
    
    Xred = BestCoeff(fx, coeff);
    Yred = BestCoeff(fy, coeff);
    
    lbdist = sqrt(sum(abs(Xred - Yred).^2));
end

function X = BestCoeff(X, coeff)

Y = abs(X).^2;
%sum(Y)
[Ysorted Yorder] = sort(-Y);           % sort descending
Ysorted = cumsum(-Ysorted)/sum(Y);
X(Yorder((coeff+1):end)) = 0;

end

function lb = lb_keogh(T, Q, U, L)
	T = T.';
	Q = Q.';
	lb = sqrt(sum([[T > U].* [T-U]; [T < L].* [L-T]].^2));
end

function b = lower_b(t, w)
	l = length(t);
	b = zeros(1,l).';
	for i = 1 : l
		b(i) = min(t(max(1,i-w):min(l,i+w)));
	end
end

function b = upper_b(t, w)
	l = length(t);
	b = zeros(1,l).';
	for i = 1 : l
		b(i) = max(t(max(1,i-w):min(l,i+w)));
	end
end


