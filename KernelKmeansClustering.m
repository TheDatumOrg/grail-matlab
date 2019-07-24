function mem = KernelKmeansClustering(ZExact, ZReduced, k)

    try
        SmplPoints = DualDPP_FD(ZReduced, k);
    catch
        SmplPoints = DualDPP_FD(ZExact, k);
    end
    
    
    try
        mem = kmeans(ZReduced,k,'Start',ZReduced(SmplPoints,:));
    catch
        mem = kmeans(ZExact,k,'Start',ZExact(SmplPoints,:));
    end
    
    
end