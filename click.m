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
        dos(tracer); %DOS command of previous string

        cd(path)
        files = dir('*.whiskers'); %makes list of all created whiskers files
        cd(working_directory); 
        M = size(files);
        M = M(1);
        for n = 1:M
            file = files(n);
            measures = [file.name(1:end-8) 'measurements'];
            fprintf(1,'Measuring %s\n',file.name);
            stringm = sprintf('measure --face %s "%s\\%s" "%s\\%s" ', face_hint, path, file.name, path, measures);
            dos(stringm);
        end
        fprintf('Measurement complete\n')

        cd(path)
        files = dir('*.measurements');
        cd(working_directory); 
        M = size(files);
        M = M(1);
        for n = 1:M
            file = files(n);
            fprintf(1,'Classifying %s\n',file.name);
            stringc = sprintf('classify "%s\\%s" "%s\\%s" %s --px2mm 0.04 -n %1.0f ', path, file.name, path, file.name, face_hint, whisker);
            dos(stringc);
        end
        fprintf('Classification complete\n')

        cd(path)
        files1 = dir('*.measurements');
        cd(working_directory); 

        S = size(files1);
        S = S(1);
        for n = 1:S
            try
            file = files1(n);
            fprintf(1,'Re-Classifying %s\n',file.name);
            stringc = sprintf('reclassify -n %1.0f "%s\\%s" "%s\\%s" ', whisker, path, file.name, path, file.name);
            dos(stringc);
            catch
                continue;
            end
        end
        fprintf('Reclassification complete\n')


        cd(path)
        measurements_files = dir('*.measurements');
        cd(working_directory); 

        d = size(measurements_files);
        d = d(1);
        for i = 1:d 
                file = measurements_files(i);
                B = [path '\' file.name];
                table = LoadMeasurements(B);
                cd(path)
                fprintf('Loading Measurements file for %s \n',file.name);
                name = [file.name(1:end-12) 'mat'];
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
            data_array = zeros(frames,whisker);
            figs = (whisker - 1);
            Ct = 0;
            while Ct <= figs
                groups = [groups Ct];
                Ct = Ct + 1;
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

            for t = 1:whisker
                c = {'r' 'c' 'g' 'm' 'y' 'k'};
                subplot(1,2,1);
                plot(data_array(:,t), c{t});
                hold on
            end
            H = sprintf('%s\n Individual Whisker angle', directory(i).name);
            title(H);
            xlabel('Frame');
            ylabel('Angle');
            
            
            normal = mean(data_array(1:300,:));
            data_array = bsxfun(@minus, data_array, normal);
            average_angle = nanmean(data_array, 2);
            subplot(1,2,2);
            plot(average_angle, 'b');
            H = sprintf('%s\n  Average Change in Whisker Angle', directory(i).name);
            title(H);
            xlabel('Frame');
            ylabel('Angle');
            header = directory(i).name;
            header = header(1:end-4);
            if ER > 0
                figname = sprintf('%s-ERRORS', header);
                fprintf('ERROR %s has a gap in data \n', directory(i).name);
            else 
                figname = sprintf('%s-Average', header);
                fprintf('No errors in %s\n', directory(i).name);
            end
            saveas(gcf, figname, 'fig');
            close all

        end  
    end

    function [fold_detect,file_detect] = detector(path)
        cd(path)
        b = dir();
        files = dir('*.tif');
        isub = [b(:).isdir];
        nameFolds = {b(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
        fold_detect = size(nameFolds, 1);
        file_detect = size(files, 1);
    end

        
    
[fold,fil] = detector(start_directory);
whisker_order = 0;
if fil > 0
    whisker_order = whisker_order + 1;
    whisknum = whiskers(whisker_order);
    clacker(face_hint, start_directory, whisknum);
elseif fil == 0
    fprintf('No tif files in the start directory\n');
end

if fold > 0
    target = [start_directory '\**\*.'];
    fprintf('Scanning all subdirectories from starting directory\n');
    D = rdir(target);             %// List of all sub-directories
    for k = 1:length(D)
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