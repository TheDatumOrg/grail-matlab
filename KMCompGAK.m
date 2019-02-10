function [KM, DistComp] = KMCompGAK(X, sigma)

    [m, ~] = size(X);

    KM = zeros(m,m);

    DistComp = 0;

    parfor i=1:m-1
        disp(i);
        rowi = X(i,:);
        tmpVector = zeros(1,m);
           for j=i+1:m
                rowj = X(j,:); 
                tmpVector(j) = logGAK(rowi',rowj',sigma,0);
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
        KM(i,i) = logGAK(X(i,:)',X(i,:)',sigma,0);
    end

end
