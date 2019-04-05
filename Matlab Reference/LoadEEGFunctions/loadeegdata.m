function data=loadeegdata(varargin)
% LOADEEGDATA Load raw EEG data from subject in current working directory
%   by Ang Kai Keng (kkang@i2r.a-star.edu.sg)
%
%   Syntax:
%     data=loadeegdata(subject)
%     data=loadeegdata(subject,ifiles)
%     data=loadeegdata(subject1,subject2,...)
%     data=loadeegdata(subject1,subject2,...,ifiles)
%   where
%     data:    EEG Data structure
%     subject: name of subject
%     ifile:   index of files to load (loads all by default)
%
%   Parameter:
%     keyword: specify the keyword in the datafile  (default) '_'
%
%   See also READBATCHCONTEEG, READCONTEEG.

ifile=inf;
global g_strDataFolder; %this global variable is used to specify the directory where your data is
keyword='_';
if (isempty(g_strDataFolder))
    clear g_strDataFolder;
    root_dir=pwd;
else
    root_dir=g_strDataFolder;
end

nsubject=0;
subject=[];
data_index=1;
data_path=[];
data_filename=[];
data_dir='Data';
while ~isempty(varargin)
    if ischar(varargin{1})
        switch varargin{1}
            case 'keyword'
                keyword=varargin{2};
                varargin(1)=[];
                varargin(1)=[];
            case 'rootdir'
                root_dir=varargin{2};
                varargin(1)=[];
                varargin(1)=[];
            case 'datadir'
                data_dir=varargin{2};
                varargin(1)=[];
                varargin(1)=[];
            case 'BadTrialMarks' %cannot be placed here since removeerrtrials should come first
                BadTrialMarks = varargin{2}.BadTrialMarks;
                ValidStimCode = varargin{2}.ValidStimCode;
                ValidStimPos = varargin{2}.ValidStimPos;
                ValidCodeNum = varargin{2}.ValidCodeNum;
                varargin(1)=[];
                varargin(1)=[];
            otherwise
                nsubject=nsubject+1;
                subject{nsubject}=varargin{1}; %#ok<AGROW>
                varargin(1)=[];
        end
    else
        if isnumeric(varargin{1})
            ifile=varargin{1};
            varargin(1)=[];
        end
    end
end

for isubject=1:nsubject
    if isdir([root_dir '\' subject{isubject} '\' data_dir]) %changed to include root_dir
        % Subject directory specified
        files_in_dir=dir([root_dir '\' subject{isubject} '\' data_dir]);
        files_is_dir=cell2mat({files_in_dir(:).isdir}); %added by ZY to filter out files, not FOLDERS
        files_in_dir={files_in_dir(:).name};
        files_in_dir(~files_is_dir)=[]; %added by ZY 
        
        
        for i=1:length(files_in_dir)
            if strfind(files_in_dir{i},keyword)>0 %to ask Kai Keng why this condition?
                %added by ZY to include empty data_dir 
                if isempty(data_dir)
                    mydir=[root_dir '\' subject{isubject} '\' files_in_dir{i}]; %#ok<AGROW>
                else
                    mydir=[root_dir '\' subject{isubject} '\' data_dir '\' files_in_dir{i}]; %#ok<AGROW>
                end
                files_in_subdir=dir([mydir '\*.cnt']);
                for j=1:length(files_in_subdir)
                    data_path{data_index}=mydir;
                    data_filename{data_index}=files_in_subdir(j).name; %#ok<AGROW>
                    data_index=data_index+1;
                end
            end
        end
    else
        % directory under subject specified
        files_in_dir=dir([root_dir '\' subject{isubject} '\']);
        files_in_dir={files_in_dir(:).name};
        if nargin<2
            ifile=inf;
        end
        for i=1:length(files_in_dir)
            if (strfind(files_in_dir{i},'.cnt')>0)
                data_path{data_index}=[root_dir '\' subject{isubject} '\']; %#ok<AGROW>
                data_filename{data_index}=files_in_dir{i}; %#ok<AGROW>
                data_index=data_index+1;
            end
        end
    end
end

if(isempty(data_path)) 
    data=[];
    return
end
if ifile==inf
    data=ReadBatchContEEG(data_path, data_filename);
else
    data=ReadBatchContEEG({data_path{ifile}}, {data_filename{ifile}});
end
%ZY: added functionality to accomodate the removal of bad trials
if exist('BadTrialMarks','var')
   data.BadTrialMarks = BadTrialMarks;
   data.stimcode = ValidStimCode;
   data.stimpos = ValidStimPos; 
   data.codenum = ValidCodeNum;
end

% To implement read from config file later
data.sel_chan_list={'F7';'F3';'Fz';'F4';'F8';'FT7';'FC3';'FCz';'FC4';'FT8';'T7';'C3';'Cz';'C4';'T8';'TP7';'CP3';'CPz';'CP4';'TP8';'P7';'P3';'Pz';'P4';'P8';'PO1';'PO2'};