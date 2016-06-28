function [ ] = click(face_hint,whiskers)
%CLICK automates the entirety of the Clack whisker tracker requireing only
%that the working directory be WhiskerTracking and the movies to be
%analyzed reside in a folder called data within WhiskerTracking. Input face
%hint as a string and whiskers to detect as an integer
%  

%dos('python python/batch.py data -e trace -f *.mp4')

dos('python python/batch.py data -e whisker_convert --args="whisk1" -f *.whiskers')

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

stringc = sprintf('python python/batch.py data -e classify --args="%s --px2mm 0.04 -n %f" -f *.measurements',face_hint,whiskers);
dos(stringc);

stringrc = sprintf('python python/batch.py data -e reclassify --args="-n %f" -f *.measurements', whiskers);
dos(stringrc);

measurements_files = dir('*.measurements');

for file = measurements_files 

        table = LoadMeasurements(file.name);
        save(file.name,table);      
end
clear
end

