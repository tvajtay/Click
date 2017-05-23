function [ D ] = datastruct( start_directory, whiskers )
%DATASTRUCT Function to organize optogenetic whisker data
%   The testing paradigm of the summer 2016 optogenetic testing and beyond
% uses a unique sequence of durations. This function aims to organize all
% the individual data into a 3D struct with averages and SEM included. The
% input arguement is only a string of the path to the main parent directory
% of the experiment.

tstart = tic;
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

    function [] = ds(path, whisk, Aindex, mouseindex)
        cd(path)
        movies = dir('jit*.mat');
        sw = 0;
        colnum = 1;
        depnum = 1;
        fprintf('Starting duration part 1\n');
        for t = 1:96
            switch sw
                case 0 %Protraction data input
                    dt = load(movies(t).name);
                    dt = dt.Orig(:,whisk);
                    nm = nanmean(dt(1:400,1),1);
                    dt = dt - nm;
                    rownum = size(dt,1);
                    A(Aindex).Mice(mouseindex).P(1:rownum,colnum,depnum) = dt;
                    sw = 1;
                case 1 %Retraction data input
                    dt = load(movies(t).name);
                    dt = dt.Orig(:,whisk);
                    nm = nanmean(dt(1:400,1),1);
                    dt = dt - nm;
                    rownum = size(dt,1);
                    A(Aindex).Mice(mouseindex).R(1:rownum,colnum,depnum) = dt;
                    depnum = depnum + 1;
                    sw = 0;
                    
                    if depnum == 7
                       depnum = 1;
                       colnum = colnum + 1;
                    end
            end      
        end
        
        %{
        fprintf('Starting duration part 2\n');
        for t = 97:138
            switch sw
                case 0 %Protraction data input
                    dt = load(movies(t).name);
                    dt = dt.Orig;
                    nm = nanmean(dt(1:400,1),1);
                    dt = dt - nm;
                    rownum = size(dt,1);
                    A(Aindex).Mice(mouseindex).P(1:rownum,colnum,depnum) = dt;
                    sw = 1;
                case 1 %Retraction data input
                    dt = load(movies(t).name);
                    nm = nanmean(dt(1:400,1),1);
                    dt = dt - nm;
                    rownum = size(dt,1);
                    A(Aindex).Mice(mouseindex).R(1:rownum,colnum,depnum) = dt;
                    depnum = depnum + 1;
                    sw = 0;
                    
                    if depnum == 4
                       depnum = 1;
                       colnum = colnum + 1;
                    end
            end  
        end
         %}
        A(Aindex).Mice(mouseindex).P(:,9,:) = nanmean( A(Aindex).Mice(mouseindex).P(:,1:8,:),2);
        A(Aindex).Mice(mouseindex).R(:,9,:) = nanmean( A(Aindex).Mice(mouseindex).R(:,1:8,:),2);
    end

x = NaN(1550,9,6);
d = [18 19 20 21 25 26 27 28];
m = {'F0n', 'F1n', 'M0n', 'M1n', 'M2n'};
A = struct('Date',{},'Mice',struct('Name', {},'P',[], 'R', []));

for i = 1:8
    A(i).Date = sprintf('07/%d/16',d(i));
    for j = 1:5
       A(i).Mice(j).name = m(j);
       A(i).Mice(j).P = x;
       A(i).Mice(j).R = x;
    end
end

whisker_order = 0;

target = [start_directory '\**\*.'];
fprintf('Scanning all subdirectories from starting directory\n');
D = rdir(target);             %// List of all sub-directories
Af = 1;
mf = 1;

for k = 1:length(D)
    currpath = D(k).name;
    [~,fil] = detector(currpath);
    fprintf('Checking %s for tif files\n', currpath);
    if fil >= 138
        fprintf('Starting data input\n');
        whisker_order = whisker_order + 1;
        whisknum = whiskers(whisker_order);
        ds(currpath, whisknum, Af, mf);
        mf = mf + 1;
        if mf > 5
            mf = 1;
            Af = Af + 1;
        end
    end
end

cd(working_directory);
save('nerveregendata.mat','A');

finish = datestr(now);
fprintf('Datastruct completed at %s\n', finish);
telapsed = toc(tstart);
fprintf('Datastruct ran for %.2f seconds\n', telapsed);


end

