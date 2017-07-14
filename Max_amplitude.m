x = NaN(5,9,6);
d = [18 19 20 21 25 26 27 28];
B = struct('Date',{},'P',[], 'R', []);

for i = 1:8
   B(i).Date = sprintf('07/%d/16',d(i));
   B(i).P = x;
   B(i).R = x;
end

for i = 1:8
   for j = 1:5
      for k = 1:6
          for p = 1:8
         
          a = max(A(i).Mice(j).P(400:800,p,k));
          b = min(A(i).Mice(j).R(400:800,p,k));
          
          B(i).P(j,p,k) = a;
          B(i).R(j,p,k) = b;
          end
          B(i).P(j,9,k) = nanmean(B(i).P(j,1:8,k),2);
          B(i).R(j,9,k) = nanmean(B(i).R(j,1:8,k),2);
      end
   end
end

B(9).Date = 'Total';
B(9).P = NaN(8,2,6);
B(9).R = NaN(8,2,6);

for i = 1:8
      for k = 1:6
          
          pav = nanmean(B(i).P(:,9,k));
          pem = std(B(i).P(:,9,k))/sqrt(8);
          rav = nanmean(B(i).R(:,9,k));
          rem = std(B(i).R(:,9,k))/sqrt(8);
          B(9).P(i,1,k) = pav;
          B(9).P(i,2,k) = pem;
          B(9).R(i,1,k) = rav;
          B(9).R(i,2,k) = rem;
      end
end
z = {'5','10','20','50','100','1000'};
days = [1 4 8];
for ind = 1:3
h = days(ind);
plot(permute(B(9).R(h,1,:),[3 2 1]));
hold on;
end
set(gca,'XLim',[1 6])
set(gca,'XTick',[1:1:6]);
set(gca,'XTicklabel',z');
xlabel('Durations');
ylabel('Max Angle of whisker');
legend('Day 0', 'Day 3', 'Day 10');

