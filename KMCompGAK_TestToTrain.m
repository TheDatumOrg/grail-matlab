function [KM,DistComp] = KMCompGAK_TestToTrain(X,Y,sigma)

    [nrowsX, ~]=size(X);
    [nrowsY, ~]=size(Y);

    KM = zeros(nrowsX,nrowsY);

    DistComp = 0;
    for i=1:nrowsX
            disp(i);
            tmpX = X(i,:);
            for j=1:nrowsY
                    KM(i,j) = logGAK(tmpX',Y(j,:)',sigma,0);
                    DistComp = DistComp+1;
            end    
    end
end