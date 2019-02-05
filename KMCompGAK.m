function [KM, DistComp] = KMCompGAK(X, sigma)

    [m, ~] = size(X);

    KM = zeros(m,m);

    DistComp = 0;

    for i=1:m-1
        disp(i);
        rowi = X(i,:);    
           for j=i+1:m
                rowj = X(j,:); 
                KM(i,j) = logGAK(rowi',rowj',sigma,0);
                DistComp = DistComp+1;
           end    
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
