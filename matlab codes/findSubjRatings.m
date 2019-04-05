function ratingsGrid = findSubjRatings(subject, fileList)

%returns the first two columns corresponding to subject's valence and
%arousal and third and fourth corresponds to IAPS valence and arousal for
%the pictures the subject rated.
%5th and 6th columns are the std deviations for valence and arousal by IAPS
%just incase

filename =  strcat(subject, '\DataTraining\ratings.txt');

fileID = fopen(filename,'r');

C = textscan(fileID,'%s %s %s %s');
fclose(fileID);

firstLines = C{1};
fourthLines = C{4};

[a, b] = size(firstLines);

picNames = zeros(a,1);
ratingsGrid = zeros(a,6);

fourthLines = cell2mat(fourthLines);


for i=1:a
     pic = regexp(firstLines{i}, '[\d.]+(?=.jpg)' ,'match', 'once');
     picNames(i, 1) = str2double(pic);
     fileIndex = find(fileList(:, 1) == picNames(i, 1), 1);
     
     ratingsGrid(i, 3:6) = fileList(fileIndex, 2:5);
     
     ratingsGrid(i, 1) =  str2double(fourthLines(i, 3));
     ratingsGrid(i, 2) =  str2double(fourthLines(i, 5));
     
end









% PLOT THE RATINGS GRID
% 
% r1 = rand(a,1)*.2;
% 
% x=ratingsGrid(:,2);
% y=ratingsGrid(:,1);
% scatter(x+r1,y+r1);
% dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points;
% c = picNames;
% text(x+dx, y+dy, c);
