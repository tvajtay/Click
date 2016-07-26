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
            cd(working_directory);
            
            i = 1;
            while i <= errors
                file = measurements_files(i);
                measurements_name = file.name(1:end-11);
                measurements_name = [measurements_name '.measurements'];
                B = [direction '\' measurements_name];
                table = LoadMeasurements(B);
                cd(direction)
                name = file.name(1:end-12);
                name = [name '.mat'];
                save(name, 'table');
                fprintf('Saved data matrix for %s\n', measurements_name);
                cd(working_directory);
                i = i + 1;
            end
            
            cd(direction)
            directory = measurements_files;
            
            i = 1;
            while i <= errors
                X = directory(i).name(1:end-11);
                X = [X '.mat'];
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
                H = sprintf('%s\n Individual Whisker angle', directory(i).name(1:end-11));
                title(H);
                xlabel('Frame');
                ylabel('angle');
                
                normal = mean(data_array(1:300,:));
                data_array = bsxfun(@minus, data_array, normal);
                average_angle = nanmean(data_array, 2);
                subplot(1,2,2);
                plot(average_angle, 'b');
                H = sprintf('%s\n  Average Whisker angle', directory(i).name(1:end-11));
                title(H);
                xlabel('Frame');
                ylabel('angle');
                header = directory(i).name(1:end-11);
                if ER > 0
                    figname = sprintf('%s-ERRORS', header);
                    fprintf('ERROR %s.mat has a gap in data\n', header);
                else
                    figname = sprintf('%s-Average', header);
                    fprintf('No errors in %s.mat\n', header);
                end
                saveas(gcf, figname, 'fig');
                close all
                i = i + 1;
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

