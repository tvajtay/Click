for i = 1:8
   for j = 1:5
      for k = 1:6
          for t = 1:8   % the for loop cycle through the structure
            ptable = abs(A(i).Mice(j).P(:,t,k)); %loads a single column from the raw data columns (1:8)
            rtable = abs(A(i).Mice(j).R(:,t,k)); % However it's the absolute value to find index of the beginning of movement
            x = find(ptable > 1.5, 1); % Finds the first index where angle is above the threshold
            y = find(rtable > 1, 1);
            pdiff = abs(500 - x); % Determines absolute diffrence between the found index and the arbitrary 500 frame where trigger should be
            rdiff = abs(500 - y);
            ptable = A(i).Mice(j).P(:,t,k); %reloads a single column from the raw data columns (1:8)but it is the actual data
            rtable = A(i).Mice(j).R(:,t,k);
            
            % If frame where angle starts moving is before or after 500 the
            % data is shifted accordingly
            if x < 500
                ptable(pdiff+1:end) = ptable(1:end-pdiff);
                ptable(1:pdiff) = nan(pdiff,1);
            elseif x >= 500
                ptable(1:end-pdiff) = ptable(pdiff+1:end);
            end
             A(i).Mice(j).P(:,t,k) = ptable;
             
            if y < 500
                rtable(rdiff+1:end) = rtable(1:end-rdiff);
                rtable(1:rdiff) = nan(rdiff,1);
            elseif y >= 500
                rtable(1:end-rdiff) = rtable(rdiff+1:end);
            end
            A(i).Mice(j).R(:,t,k) = rtable;
          end
          % After we correct shift the data we redo the average calculation
          % in the last column
          pm = nanmean(A(i).Mice(j).P(:,1:8,k),2);
          rm = nanmean(A(i).Mice(j).R(:,1:8,k),2);
          
          A(i).Mice(j).P(:,9,k) = pm;
          A(i).Mice(j).R(:,9,k) = rm;
      end
   end
end