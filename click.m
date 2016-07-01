function [ ] = click(face_hint,whiskers)
%CLICK automates the entirety of the Clack whisker tracker requiring only
%that: The working directory be WhiskerTracking. The movies to be
%analyzed reside in a folder called data within WhiskerTracking. There 
%exists a folder within WhiskerTracking called analyzed. And Input 'face
%hint' as a string and "whiskers" as an integer
%  

dos('python python/batch.py data -e trace -f *.tif') 

%dos('python python/batch.py data -e whisker_convert --args="whisk1" -f *.whiskers')
%command to format all whiskers files to whisk1 format turn on if recieving
%format error from the measure section below.

cd data
files = dir('*.whiskers');
cd ..
M = size(files);
M = M(1);
for n = 1:M
    file = files(n);
    measures = file.name;
    measures = measures(1:end-8);
    measures = [measures 'measurements'];
    fprintf(1,'Converting %s\n',file.name);
    stringm = sprintf('measure --face %s data/%s data/%s ', face_hint, file.name, measures);
    dos(stringm)
end
fprintf('Measurement complete')

cd data
files = dir('*.measurements');
cd ..
M = size(files);
M = M(1);
for n = 1:M
    file = files(n);
    fprintf(1,'Converting %s\n',file.name);
    stringc = sprintf('classify data/%s data/%s %s --px2mm 0.04 -n %1.0f ', file.name, file.name, face_hint, whiskers);
    dos(stringc)
end
fprintf('Classification complete')

cd data
files1 = dir('*.measurements');
cd ..
S = size(files1);
S = S(1);
for n = 1:S
    file = files1(n);
    fprintf(1,'Converting %s\n',file.name);
    stringc = sprintf('reclassify -n %1.0f data/%s data/%s ', whiskers, file.name, file.name);
    dos(stringc)
end
fprintf('Reclassification complete')


cd data
measurements_files = dir('*.measurements');
cd ..

d = size(measurements_files);
d = d(1);
for i = 1:d 
        file = measurements_files(i);
        B = ['data/' file.name];
        table = LoadMeasurements(B);
        cd analyzed
        name = file.name(1:end-12);
        name = [name 'mat'];
        save(name, 'table');
        cd ..
end

cd data
measurements_files = dir('*.measurements');
cd ..

d = size(measurements_files);
d = d(1);
for i = 1:d 
        file = measurements_files(i);
        B = ['data/' file.name];
        table = LoadMeasurements(B);
        cd analyzed
        name = file.name(1:end-12);
        name = [name 'mat'];
        save(name, 'table');
        cd ..
end

cd analyzed
directory = dir('*.mat');
F = size(directory);
F = F(1);

for i = 1:F
    X = directory(i).name;
    load(X);
    My_cell = struct2cell(table);
    My_cell = My_cell';
    My_cell = cellfun(@(x) single(x),My_cell);
    rows = size(My_cell);
    rows = rows(1);
    frames = max(My_cell(:,1));
    groups = [];
    data_array = zeros(frames,whiskers);
    figs = (whiskers - 1);
    while figs >= 0
        groups = [groups figs];
        figs = figs - 1;
    
    end
    
    for j = 1:rows
        if My_cell(j,3) < 0;
        else
            L = find(My_cell(j,3) == groups);
            frame = (My_cell(j,1) + 1);
            data_array(frame, L) = My_cell(j,8);
        end
    end
    
    for t = 1:whiskers
        c = {'g' 'r' 'c' 'm' 'y' 'k'};
        plot(data_array(:,t), c{t});
        hold on
    end
    H = sprintf('%s\n Whisker angle', directory(i).name);
    title(H);
    xlabel('Frame');
    ylabel('angle');
    header = directory(i).name;
    header = header(1:end-4);
    figname = sprintf('%s-Individual Whiskers', header);
    saveas(gcf, figname, 'fig');
    close all
    average_angle = mean(data_array, 2);
    plot(average_angle, 'b');
    H = sprintf('%s\n  Average Whisker angle', directory(i).name);
    title(H);
    xlabel('Frame');
    ylabel('angle');
    header = directory(i).name;
    header = header(1:end-4);
    ER = find(data_array == 0);
    if ER > 0
        figname = sprintf('%s-ERRORS', header);
    else 
        figname = sprintf('%s-Average', header);
    end
    saveas(gcf, figname, 'fig');
    close all
    
end

end

