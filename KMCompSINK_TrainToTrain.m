function [KM, DistComp] = KMCompSINK_TrainToTrain(X, sigma)

    [m, ~] = size(X);

    KM = zeros(m,m);

    DistComp = 0;

    for i=1:m-1
        disp(i);
        rowi = X(i,:);
        tmpVector = zeros(1,m);
           for j=i+1:m
                rowj = X(j,:); 
                tmpVector(j) = SINK(rowi,rowj,sigma);
                DistComp = DistComp+1;
           end    
        KM(i,:) = tmpVector;   
    end

    for i=1:m-1
           for j=i+1:m
                KM(j,i) = KM(i,j);
           end    
    end

    for i=1:m
        KM(i,i) = SINK(X(i,:),X(i,:),sigma);
    end

end
