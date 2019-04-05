clear;
clc;
datadir = 'C:\Users\User\Documents\SRP\matlab\Matlab Reference\LoadEEGFunctions\';
dataTrainingFolder = 'DataTraining';

subjects = {'XiaMian','ZhengYang','Yiheng','Tiffany','XiangJun'};
subjChoice = [1 2 3 4 5];

celldata = cellstr(subjects);
for index=subjChoice;
    subject = subjects{1,index};
    pxxSubj = loadPxxSubjAny(subject);
    pxxEveryone(:,:,:,:,index) = pxxSubj(:,:,:,:);
end


