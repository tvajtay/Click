function [] = jitter(start_directory)

tstart = tic();
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

    function [] = jit(curr_file)     %The actual function
        Tiff = imread(curr_file);
        
    end
    
[fold,fil] = detector(start_directory);

if fil > 0
    for n = 1:size(fil,1)
        jit(fil(n));
    end
elseif fil == 0
    fprintf('No tif source files in the start directory\n');
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
            % Insert code to correct jitter here for subdirectories
        end
    end
    finish = datestr(now);
    fprintf('Jitter completed at %s\n', finish);
    cd(working_directory);
    telapsed = toc(tstart);
    fprintf('Jitter ran for %.2f seconds\n', telapsed);
elseif fold == 0
    finish = datestr(now);
    cd(working_directory);
    fprintf('Jitter completed at %s\n', finish);
    telapsed = toc(tstart);
    fprintf('Jitter ran for %.2f seconds\n', telapsed);
end
end