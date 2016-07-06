function [] = redo(whiskers, path)
%REDO a offshoot of the click function that will re-plot the figures for
%the individual and average whiskers after the re-tracking/corrections made
%to the whiskers files via the Clack WhiskerTracking GUI. Input arguments
%are an integer value of the number of whiskers and the path to the data
%directory as a string.
% Tom Vajtay 07/2016 Rutgers University


working_directory = 'C:\Users\margolislab\Desktop\WhiskerTracking'; %modify this pathway to the WhiskerTracking directory

cd(path);
measurements_files = dir('*.measurements');
previous_figs = dir('*.fig');
delete(previous_figs.name);
cd(working_directory);
d = size(measurements_files);
d = d(1);
for i = 1:d 
        file = measurements_files(i);
        B = [path '\' file.name];
        table = LoadMeasurements(B);
        cd(path)
        name = file.name(1:end-12);
        name = [name 'mat'];
        save(name, 'table');
        fprintf('Saved data matrix for %s\n', file.name);
        cd(working_directory);

end

cd(path)
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
        subplot(1,2,1);
        plot(data_array(:,t), c{t});
        hold on
    end
    H = sprintf('%s\n Whisker angle', directory(i).name);
    title(H);
    xlabel('Frame');
    ylabel('angle');
    %header = directory(i).name;
    %header = header(1:end-4);
    ER = sum(find(data_array == 0));
    %if ER > 0
     %   header = [header '-ERRORS'];
    %end
    %figname = sprintf('%s-Individual Whiskers', header);
    %saveas(gcf, figname, 'fig');
    %close all
    average_angle = mean(data_array, 2);
    subplot(1,2,2);
    plot(average_angle, 'b');
    H = sprintf('%s\n  Average Whisker angle', directory(i).name);
    title(H);
    xlabel('Frame');
    ylabel('angle');
    header = directory(i).name;
    header = header(1:end-4);
    if ER > 0
        figname = sprintf('%s-ERRORS', header);
        fprintf('ERROR %s has a gap in data, please rectify \n', directory(i).name);
    else 
        figname = sprintf('%s-Average', header);
        fprintf('No errors in %s\n', directory(i).name);
    end
    saveas(gcf, figname, 'fig');
    close all
    
end
fprintf('Redo complete \n');
cd(working_directory);

end

