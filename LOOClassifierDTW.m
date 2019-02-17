function acc = LOOClassifierDTW(DS,window)
          
    acc = 0;

    for id = 1 : DS.TrainInstancesCount

        disp(id);
        classify_this = DS.Train(id,:);

        best_so_far = inf;

        distances = ones(DS.TrainInstancesCount,1)*inf;

        for i = 1 : DS.TrainInstancesCount

            if (i ~= id)

                compare_to_this = DS.Train(i,:);

                distances(i) = dtw(classify_this,compare_to_this,window);
                
            end

        end
        
        for i = 1 : DS.TrainInstancesCount

            if (i ~= id)

                if distances(i) < best_so_far
                    class = DS.TrainClassLabels(i);
                    best_so_far = distances(i);
                end
                
            end

        end

        if (DS.TrainClassLabels(id) == class)
            acc = acc + 1;
        end

    end
    
    acc = acc / DS.TrainInstancesCount;

end

