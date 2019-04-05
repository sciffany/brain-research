function fileList = loadRatings()

%reads the IAPS rating file. the first column corresponds to the IAPS
%picture number. the second and third column corresponds to IAPS valence
%and arousal rating and then 4th and 5th columns being their standard
%devations


IAPSfile =  'ratings.txt';
fileID = fopen(IAPSfile, 'r');

D = textscan(fileID,'%s %s %s %s %s %s %s');
fclose(fileID);

fileList(:,1) = str2double(D{2});


valenceR = D{3};

fileList(:,2) = str2double(regexp(valenceR, '[\d.]+(?=\()' ,'match', 'once')); 
fileList(:,4)= str2double(regexp(valenceR, '(?<=\()[\d.]+(?=\))' ,'match', 'once'));


arousalR = D{4}; 
fileList(:,3) = str2double(regexp(arousalR, '[\d.]+(?=\()' ,'match', 'once')); 
fileList(:,5)= str2double(regexp(arousalR, '(?<=\()[\d.]+(?=\))' ,'match', 'once'));
