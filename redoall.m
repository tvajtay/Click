function [] = redoall( start_directory )
%REDOALL Does the tail end of Click using only the existing/corrected
%measurements files for all files in the directory
%   Redo and Redoall are designed to be used while correcting whisker
%   tracking data. When you save your corrections in the Whiski GUI it
%   modifies the whiskers and measurements files accordingly. Redo and Redo
%   all use those corrected files to overwrite the previous figures and mat
%   files. Since the all the whisker data is already in the measurements
%   file, only the parent directory is needed as an input arguement.


tstart = tic;
working_directory = cd;
addpath(cd)
addpath matlab
addpath(start_directory);
set(0, 'DefaulttextInterpreter', 'none')

function [fold_detect,file_detect] = detector(path) %Goes through the directory of 'path' and outputs the number of files and subfolders
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
    d = size(measurements_files, 1);
    for i = 1:d 
            cd(working_directory);
            file = measurements_files(i);
            B = [direction '\' file.name];
            table = LoadMeasurements(B);
            table = struct2cell(table);
            table = table';
            table = [table(:,1) table(:,3) table(:,8)];
            table = cellfun(@(x) single(x), table);
            rows = size(table,1);
            frames = max(table(:,1));
            whisks = (max(table(:,2)) + 1);
            data_array = nan(frames,whisks);
            figs = (whisks - 1);
            groups = (0:figs);
            for j = 1:rows
                if table(j,2) >= 0;
                    L = table(j,2) == groups;
                    frame = (table(j,1) + 1);
                    data_array(frame, L) = table(j,3);
                end
            end
            name = file.name(1:end-12);
            name = [name 'mat'];
            cd(direction)
            save(name, 'data_array');
            
            for t = 1:whisks
                c = {'g' 'r' 'c' 'm' 'y' 'k'};
                subplot(1,2,1);
                plot(data_array(:,t), c{t});
                hold on
            end
            H = sprintf('%s\n Individual Whisker angle', name(1:end-4));
            title(H);
            xlabel('Frame');
            ylabel('angle');

            normal = nanmean(data_array(1:300,:));
            data_array = bsxfun(@minus, data_array, normal);
            average_angle = nanmean(data_array, 2);
            subplot(1,2,2);
            plot(average_angle, 'b');
            H = sprintf('%s\n  Average Whisker angle', name(1:end-4));
            title(H);
            xlabel('Frame');
            ylabel('angle');
            header = name(1:end-4);
            ER = sum(sum(isnan(data_array(350:600,:)),1),2);
            if ER > 0
                figname = sprintf('%s-ERRORS', header);
                fprintf('ERROR %s.mat has a critical gap in data\n', header);
            else
                figname = sprintf('%s-Average', header);
                fprintf('No errors in %s.mat\n', header);
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
    fprintf('No measurements files in the start directory\n');
end

if fold > 0
    target = [start_directory '\**\*.'];
    fprintf('Scanning all subdirectories from starting directory, please wait\n');
    D = rdir(target);             %// List of all sub-directories
    for k = 1:length(D)
        currpath = D(k).name;
        [~,fil] = detector(currpath);
        fprintf('Checking %s for measurements files\n', currpath);
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

