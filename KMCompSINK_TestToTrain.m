function [KM,DistComp] = KMCompSINK_TestToTrain(X,Y,sigma)

    [nrowsX, ~]=size(X);
    [nrowsY, ~]=size(Y);

    KM = zeros(nrowsX,nrowsY);

    DistComp = 0;
    for i=1:nrowsX
            disp(i);
            tmpX = X(i,:);
            for j=1:nrowsY
                    KM(i,j) = SINK(tmpX,Y(j,:),sigma);
                    DistComp = DistComp+1;
            end    
    end
end