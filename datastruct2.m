function [] = datastruct2( start_directory, whiskers )
%DATASTRUCT Function to organize optogenetic whisker data
%   The testing paradigm of AB 2017 optogenetic testing
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

function [] = ds(path, whisk, Aindex, mouseindex, sw)
    cd(path)
    movies = dir('*.mat');
    colnum = 1;
    depnum = 1;
    fprintf('Starting duration part 1\n');
    for t = 1:64
        switch sw
            case 0 %Baseline data input
                dt = load(movies(t).name);
                dt = struct2cell(dt);
                dt = dt{1,1};
                nm = nanmean(dt(1:400,:),1);
                dt = bsxfun(@minus,dt,nm);
                dt = dt(:,whisk);
                rownum = size(dt,1);
                A(Aindex).Mice(mouseindex).Baseline(1:rownum,colnum,depnum) = dt;
                depnum = depnum + 1;
                if depnum == 9
                   depnum = 1;
                   colnum = colnum + 1;
                end
            case 1 %Vehicle data input
                dt = load(movies(t).name);
                dt = struct2cell(dt);
                dt = dt{1,1};
                nm = nanmean(dt(1:400,:),1);
                dt = bsxfun(@minus,dt,nm);
                dt = dt(:,whisk);
                rownum = size(dt,1);
                A(Aindex).Mice(mouseindex).Vehicle(1:rownum,colnum,depnum) = dt;
                depnum = depnum + 1;
                if depnum == 9
                   depnum = 1;
                   colnum = colnum + 1;
                end

            case 2 %Drug Data
                dt = load(movies(t).name);
                dt = struct2cell(dt);
                dt = dt{1,1};
                nm = nanmean(dt(1:400,:),1);
                dt = bsxfun(@minus,dt,nm);
                dt = dt(:,whisk);
                rownum = size(dt,1);
                A(Aindex).Mice(mouseindex).Drug(1:rownum,colnum,depnum) = dt;
                depnum = depnum + 1;
                if depnum == 9
                   depnum = 1;
                   colnum = colnum + 1;
                end
            case 3 %Baseline2 data input
                dt = load(movies(t).name);
                dt = struct2cell(dt);
                dt = dt{1,1};
                nm = nanmean(dt(1:400,:),1);
                dt = bsxfun(@minus,dt,nm);
                dt = dt(:,whisk);
                rownum = size(dt,1);
                A(Aindex).Mice(mouseindex).Baseline2(1:rownum,colnum,depnum) = dt;
                depnum = depnum + 1;
                if depnum == 9
                   depnum = 1;
                   colnum = colnum + 1;
                end
        end      
    end

    A(Aindex).Mice(mouseindex).Baseline(:,9,:) = nanmean( A(Aindex).Mice(mouseindex).Baseline(:,1:8,:),2);
    A(Aindex).Mice(mouseindex).Vehicle(:,9,:) = nanmean( A(Aindex).Mice(mouseindex).Vehicle(:,1:8,:),2);
end

 
whisker_order = 0;
mtype = [0 1 0 1 0 1 0 1 0 1 2 2 2 2 2 0 2 0 2 0 2 0 2 0 2 0 3 0 3 0 3 0 3 0 3];
mlist = [0 1 0 1 0 1 0 1 0 1 1 1 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1];

x = NaN(1550,9,8);
m = {'M1', 'M2', 'M3', 'M4', 'M5'};
A(1:2) = struct('Mice',struct('Name', {},'Baseline',[],'Vehicle',[],'Drug',[],'Baseline2',[]));

for i = 1:2
    for j = 1:5
       A(i).Mice(j).Name = m(j);
       A(i).Mice(j).Baseline = x;
       A(i).Mice(j).Baseline2 = x;
       A(i).Mice(j).Vehicle = x;
       A(i).Mice(j).Drug = x;
    end
end


target = [start_directory '\**\*.'];
fprintf('Scanning all subdirectories from starting directory\n');
D = rdir(target);             %// List of all sub-directories
Af = 1;
mf = 1;
counter = 1;
lesiontrigger = 0;

for k = 1:length(D)
    currpath = D(k).name;
    [~,fil] = detector(currpath);
    fprintf('Checking %s for tif files\n', currpath);
    if fil == 64
        fprintf('Starting data input\n');
        whisker_order = whisker_order + 1;
        whisknum = whiskers(whisker_order);
        flag = mtype(counter);
        ds(currpath, whisknum, Af, mf, flag);
        
        mf = mf + mlist(counter);
      
        if mf > 5
            mf = 1;
            lesiontrigger = lesiontrigger + 1;
            if lesiontrigger == 2
                Af = Af + 1;
            end
        end
    end
end

cd(working_directory);
save('EMX_drug.mat','A');

finish = datestr(now);
fprintf('Datastruct completed at %s\n', finish);
telapsed = toc(tstart);
fprintf('Datastruct ran for %.2f seconds\n', telapsed);


end
