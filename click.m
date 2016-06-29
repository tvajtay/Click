function [ ] = click(face_hint,whiskers)
%CLICK automates the entirety of the Clack whisker tracker requiring only
%that: The working directory be WhiskerTracking. The movies to be
%analyzed reside in a folder called data within WhiskerTracking. There 
%exists a folder within WhiskerTracking called analyzed. And Input 'face
%hint' as a string and "whiskers" as an integer
%  

dos('python python/batch.py data -e trace -f *.tif')

%dos('python python/batch.py data -e whisker_convert --args="whisk1" -f *.whiskers')

cd data
files = dir('*.whiskers');
cd ..
W = size(files);
W = W(1);
for n = 1:W
    file = files(n);
    measures = file.name;
    measures = measures(1:end-8);
    measures = [measures 'measurements'];
    fprintf(1,'Converting %s\n',file.name)
    stringm = sprintf('measure --face %s data/%s data/%s ', face_hint, file.name, measures)
    dos(stringm)
end
fprintf('Conversion complete')

stringc = sprintf('python python/batch.py data -e classify --args="%s --px2mm 0.04 -n %1.0f" -f *.measurements',face_hint,whiskers);
dos(stringc);

stringrc = sprintf('python python/batch.py data -e reclassify -f *.measurements');
dos(stringrc);

cd data
measurements_files = dir('*.measurements');
cd ..

d = size(measurements_files);
d = d(1);
for i = 1:d 
        file = measurements_files(i);
        B = ['data/' file.name];
        table = LoadMeasurements(B);
        cd analyzed
        file.name = file.name(1:end-12);
        file.name = [file.name 'mat'];
        name = file.name;
        save(name, 'table');
        cd ..
end
clear
end

