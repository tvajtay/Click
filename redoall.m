function [] = redoall( start_directory )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
tstart = tic;
working_directory = cd;
addpath(cd)
addpath matlab
addpath(start_directory);

function [fold_detect,file_detect] = detector(path)
        cd(path)
        b = dir();
        files = dir('*.whiskers');
        isub = [b(:).isdir];
        nameFolds = {b(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
        fold_detect = size(nameFolds, 1);
        file_detect = size(files, 1);
end

function redo_1(direction)
    cd(direction);
    measurements_files = dir('*.measurements');
    previous_figs = dir('*.fig');
    if size(previous_figs, 1) > 0
    delete(previous_figs.name);
    end
    cd(working_directory);
    d = size(measurements_files, 1);
    for i = 1:d 
            file = measurements_files(i);
            B = [direction '\' file.name];
            table = LoadMeasurements(B);
            cd(direction)
            name = file.name(1:end-12);
            name = [name 'mat'];
            save(name, 'table');
            fprintf('Saved data matrix for %s\n', file.name);
            cd(working_directory);

    end

    cd(direction)
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
        whisks = (max(My_cell(:,3)) + 1);
        groups = [];
        data_array = zeros(frames,whisks);
        figs = (whisks - 1);
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
        
        ER = size(find(data_array == 0), 1);
        if ER > 0
           data_array(data_array == 0) = NaN;
        end
        save(X, 'data_array');
        
        for t = 1:whisks
            c = {'g' 'r' 'c' 'm' 'y' 'k'};
            subplot(1,2,1);
            plot(data_array(:,t), c{t});
            hold on
        end
        H = sprintf('%s\n Individual Whisker angle', directory(i).name(1:end-3));
        title(H);
        xlabel('Frame');
        ylabel('angle');

        normal = mean(data_array(1:300,:));
        data_array = bsxfun(@minus, data_array, normal);
        average_angle = nanmean(data_array, 2);
        subplot(1,2,2);
        plot(average_angle, 'b');
        H = sprintf('%s\n  Average Whisker angle', directory(i).name(1:end-3));
        title(H);
        xlabel('Frame');
        ylabel('angle');
        header = directory(i).name(1:end-3);
        if ER > 0
            figname = sprintf('%s-ERRORS', header);
            fprintf('ERROR %smat has a gap in data\n', header);
        else
            figname = sprintf('%s-Average', header);
            fprintf('No errors in %smat\n', header);
        end
        saveas(gcf, figname, 'fig');
        close all

    end
    cd(working_directory);
end

[fold,fil] = detector(start_directory);
if fil > 0
    redo_1(start_directory);
elseif fil == 0
    fprintf('No whiskers files in the start directory\n');
end

if fold > 0
    target = [start_directory '\**\*.'];
    fprintf('Scanning all subdirectories from starting directory, please wait\n');
    D = rdir(target);             %// List of all sub-directories
    for k = 1:length(D)
        currpath = D(k).name;
        [~,fil] = detector(currpath);
        fprintf('Checking %s for whiskers files\n', currpath);
        if fil > 0
            redo_1(currpath);
        end
    end
    finish = datestr(now);
    fprintf('Redoall completed at %s\n', finish);
    cd(working_directory);
    telapsed = toc(tstart);
    fprintf('Redoall ran for %.2f seconds\n', telapsed);
elseif fold == 0
    finish = datestr(now);
    fprintf('Redoall completed at %s\n', finish);
    telapsed = toc(tstart);
    fprintf('Redoall ran for %.2f seconds\n', telapsed);
end

end

