%http://stackoverflow.com/questions/10855461/knn-algo-in-matlab

function [cacc cConMat] = classify(xdata,ydata,kFolds,K, accMeasure)
%xdata is ntrials x nfeatures matrix i.e. each column is a feature
%ydata is the labels of the data in  a ntrials x 1 vector
%kFolds = number of folds for cross validation



rand('twister',pi);
data.x = xdata;
data.y = ydata;

classlabels = unique(ydata);
nClasses = length(classlabels);


%indices = crossvalind('Kfold', data.y, kFolds, 'Classes', classlabels);
if kFolds  == 0
    %lEAVE-ONE-OUT
    indices = 1:length(data.y);
else
    indices = crossvalind('Kfold', data.y, kFolds, 'Classes', classlabels);
end



%cConMat = zeros(nClasses,nClasses);
for i = 1:max(indices)
    test = indices == i;
    train = ~test;
    td = data.x(train,:);%training data
    cd = data.x(test,:);%validation data 
    trainlabels = data.y(train,:);
    testlabels = data.y(test,:);
    
    %perform feature selection based on fisher ratio
    %note that feature selection should only be done using the features and
    %labels from training data and not the validation data
    %10 = means selecting the top 10 features (but it will not be exactly
    %10 because we have 3 classes of data, hardcoded. shouldnt be hardcoded
    fs = fsfr([td trainlabels],3);
    td = data.x(train,fs);%training data
    cd = data.x(test,fs);%validation data 

    %classification
    %D = pdist2(cd,td,'euclidean');
    D = pdist2online(cd,td,'euclidean');
    
    
    [D,idx] = sort(D,2,'ascend'); %smallest distance
    D1 = D(:,1:K);
    idx1 = idx(:,1:K);
    
    %majority vote
    if sum(test)==1 %only 1 test trial
        prediction = mode(trainlabels(idx1));
    else
        prediction = mode(trainlabels(idx1),2);
    end
    
    %get the confusion matrix
    %C = confusionmat(testlabels, prediction);
    
    %C = confusionmatOnline(testlabels,prediction);
    C = getconfusemat2(prediction,testlabels,classlabels,false);
    
    if i == 1
        cConMat = C;
    else
       cConMat = cConMat + C; 
    end
end

switch accMeasure
    case 'acc'
        cacc = sum(diag(cConMat))/sum(cConMat(:));
    case 'kappa'
        cacc = calKappa(cConMat);
end






return;