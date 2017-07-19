function [] = redo(start_directory)
%REDO a offshoot of the click function that will re-plot the figures for
%the individual and average whiskers after the re-tracking/corrections made
%to the whiskers files via the Clack WhiskerTracking GUI. Input argument is
% the path to the data directory as a string.
% Tom Vajtay 07/2016 Rutgers University

tstart = tic;
working_directory = cd;
addpath(cd)
addpath matlab
addpath(start_directory);

    function redo_1(direction)
        cd(direction);
        previous_figs = dir('*ERRORS.fig');
        errors = size(previous_figs, 1);
        if errors > 0
            measurements_files = previous_figs;
            delete(previous_figs.name);
            
            for i = 1:errors 
                cd(working_directory);
                file = measurements_files(i).name(1:17);
                B = [direction '\' file '.measurements'];
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
                name = [file '.mat'];
                cd(direction)
                save(name, 'data_array');

                 c = {'r' 'g' 'b' 'm' 'y' 'c'};
                for t = 1:whisks
                    subplot(1,2,1);
                    plot(data_array(:,t), c{t});
                    hold on
                end
                H = sprintf('%s\n Individual Whisker angle', name(1:end-4));
                title(H);
                xlabel('Frame');
                ylabel('angle');

                normal = nanmean(data_array(1:300,:)); %Finds average during "quiet" initial period
                data_array = bsxfun(@minus, data_array, normal); %Subtracts baseline from all data to normalize data
                average_angle = nanmean(data_array, 2); %Averages normalized whiskers to get average movement
                subplot(1,2,2);
                plot(average_angle, 'k');
                H = sprintf('%s\n  Average Whisker angle', name(1:end-4));
                title(H);
                xlabel('Frame');
                ylabel('angle');
                header = name(1:end-4);
                ER = sum(sum(isnan(data_array(350:800,:)),1),2); %Do gaps in data exist during stimuli
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
    end
        
    function [fold_detect,file_detect] = detector(path)
        cd(path)
        b = dir();
        files = dir('*ERRORS.fig');
        isub = [b(:).isdir];
        nameFolds = {b(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
        fold_detect = size(nameFolds, 1);
        file_detect = size(files, 1);
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
            fprintf('Checking %s for ERRORS files\n', currpath);
            if fil > 0
                fprintf('ERRORS found!\n');
                redo_1(currpath);
            end
        end
        finish = datestr(now);
        fprintf('Redo completed at %s\n', finish);
        cd(working_directory);
        telapsed = toc(tstart);
        fprintf('Redo ran for %.2f seconds\n', telapsed);
    elseif fold == 0
        cd(working_directory);
        finish = datestr(now);
        fprintf('Redo completed at %s\n', finish);
        telapsed = toc(tstart);
        fprintf('Redo ran for %.2f seconds\n', telapsed);
    end

end

