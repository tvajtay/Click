function [ ] = click(face_hint, start_directory, whiskers)
%CLICK automates the entirety of the Clack whisker tracker. 
%Input 'facehint' and 'start_directory' as a string and "whiskers" as a
%series of integers seperated by spaces within brackets.
%usage: click('left', 'C:\Users\USER\Desktop\YOUR_START_DIRECTORY', [n n]);
%Tom Vajtay 07/2016 Rutgers University
%  

tstart = tic;
working_directory = cd;
addpath(cd)
addpath matlab
addpath(start_directory);

    function clacker(face_hint, path, whisker)
        cd(working_directory);
        tracer = sprintf('C:/Python27/python python/batch.py "%s" -e trace -f *.tif', path); %Formats command for DOS entry
        dos(tracer); %DOS command of previous string, batch.py function (trace parallel proccessor)

        cd(path)
        files = dir('*.whiskers'); %makes list of all created whiskers files
        cd(working_directory); %Returns to original working directory to have Whisk executables on path
        
        M = size(files,1);
        for n = 1:M %Sequential loads and measures all whiskers files in the current directory
            measures = [files(n).name(1:end-8) 'measurements']; %Modifies filename for corresponding measurements file
            fprintf(1,'Measuring %s\n',files(n).name);
            stringm = sprintf('measure --face %s "%s\\%s" "%s\\%s" ', face_hint, path, files(n).name, path, measures);
            dos(stringm); %DOS command to run measurements.exe
        end
        
        fprintf('Measurement complete\n')

        cd(path)
        files = dir('*.measurements'); %Creates List of Measurements files and their path
        cd(working_directory); 
        M = size(files,1);
        for n = 1:M
            try
            fprintf(1,'Classifying %s\n',files(n).name);
            stringc = sprintf('classify "%s\\%s" "%s\\%s" %s --px2mm 0.08 -n %1.0f ', path, files(n).name, path, files(n).name, face_hint, whisker);
            dos(stringc); %DOS command for classify.exe, classify and re-classify do not create new files, but modify the existing measurements files
            catch
                continue;
            end
        end
        fprintf('Classification complete\n')

        cd(path)
        files1 = dir('*.measurements');
        cd(working_directory); 

        S = size(files1,1);
        for n = 1:S
            try
            fprintf(1,'Re-Classifying %s\n',files1(n).name);
            stringc = sprintf('reclassify -n %1.0f "%s\\%s" "%s\\%s" ', whisker, path, files1(n).name, path, files1(n).name);
            dos(stringc);
            catch
                continue;
            end
        end
        fprintf('Reclassification complete\n')


        cd(path)
        measurements_files = dir('*.measurements');

        d = size(measurements_files,1);
        for i = 1:d 
            cd(working_directory);
            file = measurements_files(i);
            B = [path '\' file.name];
            table = LoadMeasurements(B); %Loads Measurements into a structure 
            table = struct2cell(table); %Converting structure into cell array
            table = table'; %Need to transpose as converting to cell array makes the data horizontal (?)
            table = [table(:,1) table(:,3) table(:,8)]; %Selects the Frame ID, Whisker ID, and Angle from the measurements cell array.
            table = cellfun(@(x) single(x), table); %Changes the data type to single so we can do math
            rows = size(table,1);
            frames = max(table(:,1)); %Find the number of frames of current movie
            whisks = (max(table(:,2)) + 1); %Since Whisk starts counting at 0 we add one for matlab
            data_array = nan(frames,whisks); %Pre allocate matrix for data/speed
            figs = (whisks - 1);
            groups = (0:figs); %Creates row vector of the possible Whisker ID's
            for current_row = 1:rows %Cycle through all rows of measurements array
                if table(current_row,2) >= 0 %If whisker candidate is labeled as a real whisker
                    WID = table(current_row,2) == groups; %Find which whisker the row corresponds to
                    frame = (table(current_row,1) + 1); %Find the frame the data represents, add 1 since Whisk starts at 0
                    data_array(frame, WID) = table(current_row,3); %Populate matrix at Row == frame and Column == WID with angle data
                end
            end
            name = file.name(1:end-12);
            name = [name 'mat']; %#ok<AGROW>
            cd(path)
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
    end

    function [fold_detect,file_detect] = detector(path) % Function to report number of tiff files and folders in current directory
        cd(path)
        b = dir();
        files = dir('*.tif');
        isub = [b(:).isdir];
        nameFolds = {b(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
        fold_detect = size(nameFolds, 1);
        file_detect = size(files, 1);
    end

        
    
[fold,fil] = detector(start_directory); %To check if Tiff files already present in starting directory and to analyze them
whisker_order = 0;
if fil > 0
    whisker_order = whisker_order + 1;
    whisknum = whiskers(whisker_order);
    clacker(face_hint, start_directory, whisknum);
elseif fil == 0
    fprintf('No tif files in the start directory\n');
end

if fold > 0 %Sub-folders present
    target = [start_directory '\**\*.']; %Append start directory path name with all sub folders for rdir
    fprintf('Scanning all subdirectories from starting directory\n');
    
    D = rdir(target);             %List of all sub-directories
    
    for k = 1:length(D) %Goes through all folders found by rdir and checks if they contain tiff files
        currpath = D(k).name;
        [~,fil] = detector(currpath);
        fprintf('Checking %s for tif files\n', currpath);
        if fil > 0
            whisker_order = whisker_order + 1;
            whisknum = whiskers(whisker_order);
            clacker(face_hint, currpath, whisknum);
        end
    end
    
    finish = datestr(now);
    fprintf('Click completed at %s\n', finish);
    cd(working_directory);
    telapsed = toc(tstart);
    fprintf('Click ran for %.2f seconds\n', telapsed);
    
elseif fold == 0
    finish = datestr(now);
    cd(working_directory);
    fprintf('Click completed at %s\n', finish);
    telapsed = toc(tstart);
    fprintf('Click ran for %.2f seconds\n', telapsed);
end
end