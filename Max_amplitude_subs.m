x = NaN(5,9,6);
d = [18 19 20 21 25 26 27 28];
B = struct('Date',{},'P',[], 'R', []);

for i = 1:8
   B(i).Date = sprintf('07/%d/16',d(i));
   B(i).P = x;
   B(i).R = x;
end

for i = 1:8  % Days
   for j = 1:5 %Mice
      for k = 1:6 %Duration Paradigms
          for p = 1:8 %Trials
         
          a = max(A(i).Mice(j).P(400:800,p,k)); %Find the Max movement for both Protraction and Retraction
          b = min(A(i).Mice(j).R(400:800,p,k));
          
          B(i).P(j,p,k) = a; %Fill new array with only the respective Max/min values
          B(i).R(j,p,k) = b;
          end
          B(i).P(j,9,k) = nanmean(B(i).P(j,1:8,k),2); % Last Column is the average of the Max/Mins
          B(i).R(j,9,k) = nanmean(B(i).R(j,1:8,k),2);
      end
   end
end

B(9).Date = 'Total'; % We populate a matrix for a final sub-structure for totals
B(9).P = NaN(8,2,6);
B(9).R = NaN(8,2,6);

for i = 1:8
      for k = 1:6
          
          pav = nanmean(B(i).P(:,9,k)); %We average the totals and find the SEM of all mice
          pem = std(B(i).P(:,9,k))/sqrt(8);
          rav = nanmean(B(i).R(:,9,k));
          rem = std(B(i).R(:,9,k))/sqrt(8);
          B(9).P(i,1,k) = pav;
          B(9).P(i,2,k) = pem;
          B(9).R(i,1,k) = rav;
          B(9).R(i,2,k) = rem;
      end
end
z = {'5','10','20','50','100','1000'}; %List of duration Paradigms in ms
days = {'0','1','2','3','7','8','9','10'}; % List of days after lesion
for ind = 1:6
subplot(2,3,ind);
errorbar(B(9).R(:,1,ind),B(9).R(:,2,ind));
axis([1 8 -15 0]);
set(gca,'XTick',1:1:8);
set(gca,'XTicklabel',days');
xlabel('Days After Lesion');
ylabel('Max Angle of whisker');
title(z(ind));
hold on;
end

