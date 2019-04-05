function [kappaVal kappaStdErr] = calKappa(confuseMat)

% created by Chin Zheng Yang
% N = sum(confuseMat(:));
% po = sum(diag(confuseMat))/N;
% sumRow= sum(confuseMat,2);
% sumCol = sum(confuseMat,1);
% pe = sum(sumCol(:).*sumRow(:))/(N*N);
% kappaVal = (po-pe)/(1-pe);

ntimeSamples = size(confuseMat,3);
%to handle 3d data
N = squeeze(sum(sum(confuseMat,2),1));
po = nan(1, size(confuseMat,3));
for i=1:size(confuseMat,3)
   po(i)= sum(diag(confuseMat(:,:,i)));
end
po = po(:)./N(:); %[ntime x 1]

sumRow = squeeze(sum(confuseMat,2)); %[nclass x time]
sumCol = squeeze(sum(confuseMat,1)); %[nclass x time]
%num = sum(sumRow.*sumCol,1);
num = dot(sumRow,sumCol);
den = N.*N;
pe = num(:)./den(:);
kappaVal = (po-pe)./(1-pe);

%to calculate standard error
if ntimeSamples > 1
    sumRowCol = sumRow + sumCol; 
    prodRowCol = sumRow.*sumCol;
else
    sumRowCol = sumRow + sumCol';
    prodRowCol = sumRow.*sumCol';
end

temp = sum(sumRowCol.*prodRowCol,1);
num = po + pe.^2 - temp(:)./(N.^3); 
num = sqrt(num);
den = (1 - pe).*sqrt(N);
kappaStdErr = num./den;


