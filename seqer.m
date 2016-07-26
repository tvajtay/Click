function [] = seqer( start_directory )
%SEQER Identifies seq files and deletes them from the current and all
%sub-directories
%  Usage: seqer('PATH TO DIRECTORY')
tstart = tic;
working_directory =  cd;


function [fold_detect,file_detect] = detector(path)
            cd(path)
            b = dir();
            files = dir('*.seq');
            isub = [b(:).isdir];
            nameFolds = {b(isub).name}';
            nameFolds(ismember(nameFolds,{'.','..'})) = [];
            fold_detect = size(nameFolds, 1);
            file_detect = size(files, 1);
end
    
[fold,fil] = detector(start_directory);
        if fil > 0
           seqs = dir('*.seq');
           delete(seqs.name);
        elseif fil == 0
            fprintf('No seq files in the start directory\n');
        end
        
        if fold > 0
            target = [start_directory '\**\*.'];
            fprintf('Scanning all subdirectories from starting directory, please wait\n');
            D = rdir(target);             %// List of all sub-directories
            for k = 1:length(D)
                currpath = D(k).name;
                [~,fil] = detector(currpath);
                fprintf('Checking %s for seq files\n', currpath);
                if fil > 0
                    cd(currpath)
                    seqs = dir('*.seq');
                    delete(seqs.name);
                end
            end
            finish = datestr(now);
            fprintf('Seqer completed at %s\n', finish);
            cd(working_directory);
            telapsed = toc(tstart);
            fprintf('Seqer ran for %.2f seconds\n', telapsed);
        elseif fold == 0
            finish = datestr(now);
            fprintf('Seqer completed at %s\n', finish);
            telapsed = toc(tstart);
            fprintf('Seqer ran for %.2f seconds\n', telapsed);
        end

end

