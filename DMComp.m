function [DM, DistComp] = DMComp(X, DistanceIndex)
% X is mXn matrix: m are # of time series

    [m, ~]=size(X);

    DM = zeros(m,m);

    DistComp = 0;

    for i=1:m-1   
           for j=i+1:m
                if DistanceIndex==1
                    DM(i,j) = ED(X(i,:),X(j,:));
                elseif DistanceIndex==2
                    DM(i,j) = 1-max( NCCc(X(i,:),X(j,:)) );
                end
                DistComp = DistComp+1;

                DM(j,i) = DM(i,j);
           end    
    end

end