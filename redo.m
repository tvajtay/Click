function [] = redo(whiskers)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

cd data
measurements_files = dir('*.measurements');
cd ..

delete('/analyzed/*.fig');
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
    fprintf('Finished %s\n', directory(i).name);
end

end

