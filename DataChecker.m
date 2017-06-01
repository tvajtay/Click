
for t = 1:8
    for j = 1:5
        for i = 1:6
            for y = 1:8
                x = isnan(A(t).Mice(j).P(400:600,y,i));
                x = sum(x,1);
                if x > 0
                   fprintf('Day %d, Mouse %d, in %d protraction trial has a critical error\n', t, j, y);
                end
                
                p = isnan(A(t).Mice(j).R(400:600,y,i));
                p = sum(x,1);
                if p > 0
                    fprintf('Day %d, Mouse %d, in %d retraction trial has a critical error\n', t, j, y);
                end
            end
        end
    end
end