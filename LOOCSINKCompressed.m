function acc = LOOCSINKCompressed(DS,gamma)
    
    acc = 0;
    
    for id = 1 : DS.TrainInstancesCount

        classify_this = DS.TrainFourierCompressed(id,:);
        %classify_this = DS.Train(id,:);

        best_so_far = 0;

        for i = 1 : DS.TrainInstancesCount

            if (i ~= id)

                compare_to_this = DS.TrainFourierCompressed(i,:);     
                %compare_to_this = DS.Train(i,:);    
                
                distance = SINKCompressed(compare_to_this,classify_this, gamma, DS.len);
                %distance = SINK(compare_to_this,classify_this, gamma);

                if distance > best_so_far
                    class = DS.TrainClassLabels(i);
                    best_so_far = distance;
                end
            end

        end

        if (DS.TrainClassLabels(id) == class)
            acc = acc + 1;
        end

    end
    acc = acc / DS.TrainInstancesCount;
end