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
B(9).P = NaN(8,5,6);
B(9).R = NaN(8,5,6);

for i = 1:8
  for k = 1:6
    B(9).P(i,:,k) = B(i).P(:,9,k)';
    B(9).R(i,:,k) = B(i).R(:,9,k)';
  end
end

z = {'5','10','20','50','100','1000'};
for h = 1:6
subplot(2,3,h);
for y = 1:5
plot(B(9).R(:,:,h));
hold on
axis([1 8 -20 0]);
end
title(z(h));
end

subplot(2,3,4);
xlabel('Experiment Day');
subplot(2,3,4);
ylabel('Max Angle of whisker');
m = {'F0n', 'F1n', 'M0n', 'M1n', 'M2n'};
subplot(2,3,3);
legend(m);


