function [] = sitrep( B )
%SITREP Creates Summary graphs from 2016 summer duration and intensity experiment
%   Takes a string for an argument which should be the path to the starting
%   directory of files to analyze. Function will look for all the *.mat
%   files in the directory/s and create a figure with subplots for each
%   unique *.mat file in order to determine accuracy of whisker tracker.

working_directory = cd;
addpath(working_directory);

tstart = tic;
function [fold_detect,file_detect] = detector(path)   %Detector script to search for mat file and folders and return counts for both
    cd(path)
    b = dir();
    files = dir('*.mat');
    isub = [b(:).isdir];
    nameFolds = {b(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];
    fold_detect = size(nameFolds, 1);
    file_detect = size(files, 1);
end
    

function [] = sit( file_dir )
    cd(file_dir)
    file_array = dir('*.mat');
    heading = cd;
    Y = length(dir('*.tif'));
    if Y == 138 || Y == 207 || Y == 186     %The specific # of mat files is important to make sure the subplots are organized correctly
        c = {'r' 'c' 'g' 'm' 'y' 'k'};
        for x = 1:96
            table = load(file_array(x).name);
            table = struct2array(table);
            [~,whisker] = size(table);
            subplot_tight(8,12,x);
            for t = 1:whisker
                plot(table(:,t), c{t});
                hold on
            end
            H = sprintf('%s\n', file_array(x).name);
            title(H);
            
        end
        figname = sprintf('%s_Duration_part1',heading(end-2:end));
        set(gcf,'Units','normalized');
        set(gcf,'Position',[0 0 1 1]);
        
        uicontrol('Style', 'slider', 'Callback', @sliderCallback);
        
        saveas(gcf, figname, 'png');
        
        close all  %reset figure
        j=1;
        for x = 97:138
            table = load(file_array(x).name);
            table = struct2array(table);
            [~,whisker] = size(table);
            subplot_tight(7,6,j);
            for t = 1:whisker
                plot(table(:,t), c{t});
                hold on
            end
            H = sprintf('%s\n', file_array(x).name);
            title(H);
            j = j+1;
            
        end
        
        figname = sprintf('%s_Duration_part2',heading(end-2:end));    
        saveas(gcf, figname, 'png');
        
        close all  %reset figure
        
        if Y == 207
            j = 1;
            for x = 139:183
            table = load(file_array(x).name);
            table = struct2array(table);
            [~,whisker] = size(table);
            subplot_tight(3,15,j);
                for t = 1:whisker
                    plot(table(:,t), c{t});
                    hold on
                end
            H = sprintf('%s\n', file_array(x).name);
            title(H);
            j = j + 1;
            end
        
            figname = sprintf('%s_Intensity_part1',heading(end-2:end));    
            saveas(gcf, figname, 'png');

            close all  %reset figure
            
            j = 1;
            for x = 184:207
            table = load(file_array(x).name);
            table = struct2array(table);
            [~,whisker] = size(table);
            subplot_tight(3,8,j);
                for t = 1:whisker
                    plot(table(:,t), c{t});
                    hold on
                end
            H = sprintf('%s\n', file_array(x).name);
            title(H);
            j = j+1;
            
            end
        
            figname = sprintf('%s_Intensity_part2',heading(end-2:end));
            saveas(gcf, figname, 'png');
            close all  %reset figure
        end
        
        if Y == 186
            j=1;
            for x = 139:186
            table = load(file_array(x).name);
            table = struct2array(table);
            [~,whisker] = size(table);
            subplot_tight(8,6,j);
                for t = 1:whisker
                    plot(table(:,t), c{t});
                    hold on
                end
            H = sprintf('%s\n', file_array(x).name);
            title(H);
            j = j + 1;
            
            end
        
            figname = sprintf('%s_Frequency',heading(end-2:end));    
            saveas(gcf, figname, 'png');

            close all  %reset figure
            
        end
        
            
    else
        fprintf('Number of mat files does not correspond with a known experiment.\n');
    end
    
    



end


    
[fold,fil] = detector(B);

if fil > 0
    fprintf('Mat files in starting directory, initiating report\n');
    sit(B)  
elseif fil == 0
    fprintf('No mat files in the start directory\n');
end

if fold > 0
    target = [B '\**\*.'];
    fprintf('Scanning all subdirectories from starting directory.\n');
    D = rdir(target);             %// List of all sub-directories
    for k = 1:length(D)
        currpath = D(k).name;
        [~,fil] = detector(currpath);
        fprintf('Checking %s for mat files\n', currpath);
        if fil > 0
          fprintf('Mat files detected in %s, initiating report\n', currpath);  
          sit(currpath);
        end
    end
    finish = datestr(now);
    fprintf('Sitrep completed at %s\n', finish);
    cd(working_directory);
    telapsed = toc(tstart);
    fprintf('Sitrep ran for %.2f seconds\n', telapsed);
elseif fold == 0
    finish = datestr(now);
    cd(working_directory);
    fprintf('Sitrep completed at %s\n', finish);
    telapsed = toc(tstart);
    fprintf('Sitrep ran for %.2f seconds\n', telapsed);
end

end

