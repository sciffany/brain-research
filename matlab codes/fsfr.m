function [fs,D,T]=fsfr(d,varargin)
% FSFR Feature Selection using Fisher Ratio
% Adapted from FSMIBIFPW
% by Chin Zheng Yang, Ang Kai Keng and Zhang Haihong
%   Syntax:
%     [fs,{D},{T}]=fsfr(d,{nf})
%   where
%     fs : ranked indexes of top nf features.
%     D  : auxiliary results where
%     T  : time (s) taken to perform feature selection.
%     d  : data set matrix with size [sN,sD] where
%          sN          = number of data tuples,
%          sD-1        = number of input dimensions,
%          lastcol     = class id [0..nN-1].
%     nf : number of features to select where
%          (default) nf=sD-1.
%

% Determine the size of data matrix
[stN,stD]=size(d);
nf=stD-1;
pc.opt={{'nf', nf, @isnumeric}};
pc.para={{'showwaitbar', false, @isnumeric},...
    {'nfgroup', 1, @isnumeric},...
    {'groups', 1, @isnumeric}};
parsearg(pc,varargin{:});

% Note start time
st=clock;

% Splits the data sets
otX=d(:,1:(stD-1));
otY=d(:,stD);

% Get the number of classes
clabels=unique(otY);
nc=length(clabels);

if showwaitbar
    h=waitbar(0,'FSFR computing');
end



switch nc
    case 2
        % Get the feature idx which have all 0 values
        idx = sum(otX)~=0;
        D.fr = zeros(1,size(otX,2));
        d0=otX(otY==clabels(1),idx);
        d1=otX(otY==clabels(2),idx);
        D.fr(idx) = ((mean(d0,1)-mean(d1,1)).^2)./(var(d0,[],1)+var(d1,[],1));
    otherwise
        %go with a OVR way of selecting best features
       % dbstop in fsfr at 56
        idx = sum(otX)~=0;
        D.fr = zeros(size(otX,2),nc);
        for i=1:nc
            d0=otX(otY==clabels(i),idx);
            d1=otX(otY~=clabels(i),idx);
            fr = ((mean(d0,1)-mean(d1,1)).^2)./(var(d0,[],1)+var(d1,[],1));
            D.fr(idx,i)=fr(:);
        end
end

if groups==1
    if nc==2
        mifg=vec2mat(1:stD-1,nfgroup)';
        mifsg=sum(vec2mat(D.fr,nfgroup),2);
        % Sort the MI of each group
        [D.SMC D.ISMC]=sort(mifsg,'descend');
        % Return indexes of the top nf features
        fs=reshape(mifg(:,D.ISMC(1:nf)),1,[]);
    else
        [a,b]=sort(D.fr,'descend');
        fs=b(1:nf,:);
        fs=unique(fs);%should be a row vector
        fs=fs(:)';
    end 
else
    error('Not implemented yet');
end

% Compute time elapse
T=etime(clock,st);
