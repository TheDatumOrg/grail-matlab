function DM = DM2KM(DM)
% DM is nXn distance matrix: n are # of time series

[n, ~]=size(DM);

sigma = mean(mean(DM));

for i=1:n
       for j=1:n
            DM(i,j) = exp(-DM(i,j).^2/(2*sigma^2));
       end    
end

end