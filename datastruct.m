function [ D ] = datastruct( start_directory, whiskers )
%DATASTRUCT Function to organize optogenetic whisker data
%   The testing paradigm of the summer 2016 optogenetic testing and beyond
% uses a unique sequence of durations. This function aims to organize all
% the individual data into a 3D struct with averages and SEM included. The
% input arguement is only a string of the path to the main parent directory
% of the experiment.

working_directory = cd;
addpath(cd)

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

    function [] = ds()
        
    end
x = NaN(1500,17,6);
d = [18 19 20 21 25 26 27 28];
A = struct('Date',{},'Mice',struct('Name', {},'P',[], 'R', []))

for i = 1:8
    A(i).Date = sprintf('07/%d/16',d(i));
end

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

