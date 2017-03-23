function [] = tiffcrop( start_dir, coordinates )
%TIFFCROP Crops all tiff files 
%   Detailed explanation goes here
tstart = tic;
working_directory = cd;
addpath(cd)
addpath matlab
addpath(start_dir);

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

function [] = cropp(direc, coord, filenum)
        fprintf('Tif files located, beginning to correct.\n');
        cd(direc);
        images = dir('*.tif');
        for t = 1:filenum
            curr_file = images(t).name;
            fprintf('Loading image data for %s.\n',curr_file);
            info = imfinfo(curr_file); %creates structure for every frame in tif stack
            elements = numel(info); %determine the number of frames 
            new_file = sprintf('crop-%s',curr_file);
            A = zeros(320,256,elements);
            for i = 1:elements
                A(:,:,i) = imread(curr_file, i, 'Info', info); %load greyscale values into a matrix
                fprintf('Current element: %d\n', i); 
            end
            A(:, 1:coord,:) = [];
            for j = 1:elements
            imwrite(A(:,:,j), new_file,'tif', 'WriteMode','append');
            fprintf('Current element: %d\n', j);
            end
        end 
end



coord_num = 0;
[fold,fil] = detector(start_dir);
if fil > 0
    coord_num = coord_num + 1;
    coordinate = coordinates(coord_num);
    cropp(start_dir, coordinate, fil);
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
            coord_num = coord_num + 1;
            coordinate = coordinates(coord_num);
            fprintf('Cropping photos in %s',currpath);
            cropp(currpath, coordinate, fil);
        end
    end
    
    finish = datestr(now);
    fprintf('Tiffcrop completed at %s\n', finish);
    cd(working_directory);
    telapsed = toc(tstart);
    fprintf('Tiffcrop ran for %.2f seconds\n', telapsed);
    
elseif fold == 0
    finish = datestr(now);
    cd(working_directory);
    fprintf('Tiffcrop completed at %s\n', finish);
    telapsed = toc(tstart);
    fprintf('Tiffcrop ran for %.2f seconds\n', telapsed);
end
        

end

