function [conmat,oacc,acc]= getconfusemat2(predicted,truth,classlabels,bnan)

% by Chin Zheng Yang (zychin@i2r.a-star.edu.sg)
% predicted is a 1-D array of n elements; predicted labels
% true is a 1-D array of n elements; true labels
% classlabels: 1-D array for the unique classlabels
% bnan:optional:to account for the nan class, default true
% conmat is the confusion matrix of size (nclasses+1) * (nclasses+1) to
% account for the NaN prediction (due to one against rest)
% each row represents the ground truth
% each column represents the prediction
% oacc is the overall accuracy
% acc is the accuracy for each class as a ratio of 1

bdebug = 0;
if bdebug == 1 %debug
    truth =     [0 0   0 0 0    1 1 1 1 1   0 0 0 0 0];
    predicted = [0 0   0 0 1    1 1 1 1 0   0 1 0 0 0];
    classlabels = [0 0.5 1];
    
    %truth = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4];
    %remember to handle NaNs as well
    %predicted = [nan 1 1 2 3 4 4 1 2 2 3 3 3 3 3 4 4 4 1 nan];
end

if ~exist('bnan','var')
    bnan = 1;
end

truth = truth(:);
predicted = predicted(:);
clabels = unique(classlabels);
nclasses = length(clabels);
conmat = zeros(nclasses+1); %initialize the confusion matrix, for nclasses as well as the NaN class
acc = zeros(1,nclasses);

for iclass=1:nclasses
    ilabel = clabels(iclass);
    for jclass=1:nclasses+1 %to include the Nan class here
        if jclass < nclasses+1
            jlabel = clabels(jclass);
            conmat(iclass,jclass) = sum(predicted(truth==ilabel)==jlabel);
        else
            conmat(iclass,jclass) = sum(isnan(predicted(truth==ilabel)));
        end
    end
    if sum(conmat(iclass,:)) ~=0
        acc(iclass) = conmat(iclass,iclass)/sum(conmat(iclass,:));    
    else
        acc(iclass) = NaN;
    end
end
oacc = sum(diag(conmat))/sum(conmat(:));

if ~bnan
    conmat = conmat(1:end-1,1:end-1);
end

return;