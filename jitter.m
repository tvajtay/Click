function [] = jitter(start_directory)

tstart = tic();
initial_directory = cd;

    function [fold_detect,file_detect] = detector(pathy)
            cd(pathy)
            b = dir();
            files = dir('*.tif');
            isub = [b(:).isdir];
            nameFolds = {b(isub).name}';
            nameFolds(ismember(nameFolds,{'.','..'})) = [];
            fold_detect = size(nameFolds, 1);
            file_detect = size(files, 1);
    end

     function [fold_detect,file_detect] = jdetector(pathy)
            cd(pathy)
            b = dir();
            files = dir('jit*');
            isub = [b(:).isdir];
            nameFolds = {b(isub).name}';
            nameFolds(ismember(nameFolds,{'.','..'})) = [];
            fold_detect = size(nameFolds, 1);
            file_detect = size(files, 1);
    end

    function [] = jit(curr_file)     %The actual function
        fprintf('Loading image data for %s.\n',curr_file);
        info = imfinfo(curr_file); %creates structure for every frame in tif stack
        elements = numel(info); %determine the number of frames 
        A = imread(curr_file);
        y_pixels = size(A,1);
        roi = round((y_pixels)*(0.35)); %setting up the lower and upper bounds for the roi. Selects the top and bottom 35% of image
        roil = y_pixels - roi;
        roi_1 = zeros(elements,1);
        roi_2 = zeros(elements,1);
        for i = 1:elements
            A = imread(curr_file,i,'Info',info); %load greyscale values into a matrix
            top = A(1:roi,:);
            roi_1(i) = sum(sum(top,1),2); %aggregate greyscale values into one lump sum for both roi
            bottom = A(roil:y_pixels,:);
            roi_2(i) = sum(sum(bottom,1),2);
        end
        bkg_1 = mean(roi_1(1:300)); %average first 300 frames to find baseline greyscale value
        bkg_2 = mean(roi_2(1:300));
        roi_1 = roi_1 - bkg_1; %subtract background from roi data
        roi_2 = roi_2 - bkg_2;
        a = max(roi_1);  %determine max peak for each roi for comparison in order to determine which LED turned on
        b = max(roi_2);
        
        if(a > b)           % To determine which of the two LEDs activated
            primary = roi_1;
            primary_peak = a;
        elseif(b > a)
            primary = roi_2;
            primary_peak = b;
        end
        
        detection_level = (primary_peak/2);     % find the first frame where the sum is greater than half of the max greyscale value
        t0 = find(primary > detection_level, 1);
        data = [curr_file(1:end-9) 'mat'];  %load corresponding mat file
        table = load(data);
        table = struct2array(table);
        [~,c] = size(table);  %determine number of columns
        
        if t0 < 500          %if frame with led start is before frame 500
            toadd = 500 - t0;
            B = NaN(toadd,c);
            table = [B; table];
            save(['jit_' data],'table');        %prefix added to retain original data file
            
        elseif t0 > 500     %if frame with led start is after frame 500
            tosubtract = t0 - 500;
            table = table(tosubtract:end, :);
            save(['jit_' data] , 'table');
        else %if LED on is precisely at 500 frame, it is ignored
            
        end
        
        
    end
    
    function [] = pjit(cur_file)
        B = load(cur_file);
        numof = isnan(B(1:400,:));
        if size(find(numof(:,1)),1) > 0
            Orig = load(cur_file(4:end));
            coll = size(Orig,2);
            na = nan(size(find(numof(:,1)),1),coll);
            Orig = [na; Orig];
            save(['jit' curfile], 'Orig'); 
        else
            Orig = load(cur_file(4:end));
            coll = size(Orig,2);
        end
    end


[fold,fil] = detector(start_directory);
[~,jfil] = jdectector(start_directory);
if fil > 0 && jfil == 0
    images = dir('*.tif');
    fprintf('Files in start directory,starting to correct.\n');
        for t = 1:fil
            tif_name = images(t).name;
            jit(tif_name);
        end
        
elseif jfil > 0
    jfiles = dir('jit*');
    fprintf('Files in start directory,starting to correct.\n');
    for h = 1:jfil
        jit_name = jfiles(h).name;
        pjit(jit_name);
    end
end

if fold > 0
    target = [start_directory '\**\*.'];
    fprintf('Scanning all subdirectories from starting directory\n');
    D = rdir(target);             %// List of all sub-directories
    for k = 1:length(D)
        currpath = D(k).name;
        [~,fil] = detector(currpath);
        [~,jfil] = jdetector(currpath);
        fprintf('Checking %s for tif files\n', currpath);
        if fil > 0 && jfil == 0
            % Insert code to correct jitter here for subdirectories
            fprintf('Tif files located, beginning to correct.\n');
            cd(currpath);
            images = dir('*.tif');
            for t = 1:fil
                tif_name = images(t).name;
                jit(tif_name);
            end
        elseif jfil > 0
            jfiles = dir('jit*');
            for h = 1:jfil
                jit_name = jfiles(h).name;
                pjit(jit_name);
            end
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

cd(initial_directory);
end