function norm_data = normalizedata(test,scaling)

norm_data = zeros(size(test,1),size(test,2));

for i=1:size(test,1)
        
    
    minvalue = min(test(i,:))-min(test(i,:))*scaling;
    maxvalue = max(test(i,:))+max(test(i,:))*scaling;
    
    norm_data(i,:) = (test(i,:) - minvalue) / ( maxvalue - minvalue );
    norm_data(i,:) = 1-norm_data(i,:);
end


end