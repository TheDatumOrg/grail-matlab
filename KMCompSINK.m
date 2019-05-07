function [KM, DistComp] = KMCompSINK(X,gamma)

    [m, ~] = size(X);

    KM = ones(m,m);

    DistComp = 0;

    for i=1:m-1
        disp(i)
        rowi = X(i,:);    
           for j=i+1:m
                rowj = X(j,:); 
                KM(i,j) = SINK(rowi,rowj,gamma);
                DistComp = DistComp+1;
                KM(j,i) = KM(i,j);
           end    
    end

end