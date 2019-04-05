close all
clc
datadir = 'D:\KK\Data\MI-2Class\NYGH_2013_1st_Expt';
if ~isdir(datadir)
    error('ERROR! the specific directory does not exist.');
end
stimcodes = [121 122];


dataTrainingFolder = 'DataTraining';
%dataTrainingFolder = 'DataTestingSupervised';
dataTestingFolder = 'DataTesting';
%ZhengYang2class 
%ShiLe - 2009.001 cap
%HsinYee - 2011-M02 cap
%WuYou - 2011-M02 cap (same as Hsin Yee's)


subjects={...
            'ZhengYang2Class\20130401',...
            'WuYou\20130325',...
			'HsinYee\20130320',...
            'ShiLe\20130318',...
         };
subjectsTrainFeedback = {...
                        'ZhengYang2Class\20130401',...
                        'WuYou\20130325',...
						'HsinYee\20130320',...
                        'ShiLe\20130318',...
                        };
subjectsTest = {...
					'ZhengYang2Class\20130401',...
                    'WuYou\20130325',...
                    'HsinYee\20130320',...
					'ShiLe\20130318',...	                    
				};      

subjects_short={'1','2','3','4'};
nsub = length(subjects);
chan_list = {'F7';'F3';'Fz';'F4';'F8';...
    'FT7';'FC3';'FCz';'FC4';'FT8';...
    'T7';'C3';'Cz';'C4';'T8';...
    'TP7';'CP3';'CPz';'CP4';'TP8';...
    'P7';'P3';'Pz';'P4';'P8'};
% 
% chan_list = {'FC3';'FCz';'FC4';...
%             'C3';'Cz';'C4';...
%             'CP3';'CPz';'CP4';...
%             };


bad_chs = { {},...
            {},...
            {},...
            {},...
          };

nstim64 = zeros(1,nsub);
disp('Method used: FBCSP BIF4 One versus Rest filter, time seg [0.5 2.5]');
get_input('sel_experiment',0,'Select experiment (0=10x10-fold sync cv, 1=10x10-fold async cv (kappa), 2=sync test, 3=async test (kappa):');
get_input('sel_subject',1:nsub,'Select subject to run (0=all): ');
% if sel_experiment>=2
%     get_input('sel_testdata',0,'Select test data to run (0=all, 1=AR, 2=Bar): ');
% end
if sel_subject == 0
    sel_subject = 1:nsub;
end
sel_method = 1;
for cmethod = sel_method
    for subi = sel_subject
        fprintf(['Running on subject ' num2str(subi) '...\n']);
        train_time_segment = [0.5, 2.5];
        switch sel_experiment
            case {0,2}
                %extract_time_segment=[train_time_segment(1)-1 train_time_segment(2)+0.5];
                fprintf('following Chuanchu settings\n');
                extract_time_segment=[train_time_segment(1)-0.5 train_time_segment(2)];
                test_time_segment=train_time_segment;
            case {1,3}
                train_time_interval=train_time_segment(2)-train_time_segment(1);
                extract_time_segment=[-1.5-train_time_interval,4.5];
                test_time_segment = [extract_time_segment(1)+0.5,extract_time_segment(2)-0.5];
                time_step=10;
        end

        train_time_segment = train_time_segment-extract_time_segment(1);
        test_time_segment = test_time_segment-extract_time_segment(1);
        Raw_sub = loadeegdata(subjects{subi},'rootdir', datadir,'datadir',dataTrainingFolder);
        if isempty(Raw_sub)
            error('ERROR! Lack of data in selected directory.');
        end
        Raw_sub = CorrectStimCodes(Raw_sub,stimcodes, [64 96]);
        Raw_sub = RemoveErrTrials(Raw_sub);
        sel_chan_list = chan_list;
        sel_chan_list(findch(sel_chan_list,bad_chs{subi}))=[];
        Raw_sub.sel_chan_list = sel_chan_list;
        %xsub = extracteegdata(Raw_sub,'indicate','seconds',extract_time_segment);
        %xsub = extracteegdata(Raw_sub,'indicate','seconds',extract_time_segment);
        xsub=extracteegdata(Raw_sub,'specific','seconds',extract_time_segment,'stim',stimcodes);

        clear Raw_sub;
        segtime = [0.5 2.5];
        if sel_experiment >= 2
            txsub = xsub;
            clear xsub;
            xsub.t=txsub;
            clear txsub;
            ifile = 1;

            %loading of eegdata
            Raw_sub = loadeegdata(subjectsTest{subi},'rootdir',datadir,'datadir',dataTestingFolder);
            if isempty(Raw_sub)
                error('data is not found');
            end
            Raw_sub = CorrectStimCodes(Raw_sub,stimcodes, [64 96]);
            Raw_sub=RemoveErrTrials(Raw_sub);
            Raw_sub.sel_chan_list=sel_chan_list;
            % txsub(ifile)=extracteegdata(Raw_sub,'indicate','seconds',extract_time_segment);
            txsub(ifile)=extracteegdata(Raw_sub,'specific','seconds',extract_time_segment,'stim',stimcodes);
            txsub(ifile) = reorderstimpos(Raw_sub,stimcodes,txsub(ifile));
            % end of loadeegdata for test set

            xsub.c.x=cat(3,txsub.x);
            xsub.c.y=cat(2,txsub.y);
            xsub.c.c=txsub(1).c;
            xsub.c.s=txsub(1).s;
            clear Raw_sub txsub;
        end


        stdarg={'seed',pi,'showwaitbar',false,...
            'train_time_segment',train_time_segment,...
            'test_time_segment',test_time_segment,...
            'useconfi',true };

        switch sel_experiment
            case 0
                stdarg={stdarg{:},'kfold',10,'ntimes',2};
            case 1
                stdarg={stdarg{:},'kfold',10,'ntimes',10};
                stdarg={stdarg{:},'istimeseries',true,'train_time_interval',train_time_interval,...
                    'omeasure','kappa','time_step',time_step};
            case 2
                stdarg={stdarg{:},'kfold',1,'ntimes',1};
            case 3
                stdarg={stdarg{:},'kfold',1,'ntimes',1};
                stdarg={stdarg{:},'istimeseries',true,'train_time_interval',train_time_interval,...
                    'omeasure','kappa','time_step',time_step};
        end
        if length(stimcodes)>2
            stdarg={stdarg{:},'mclassifier','multi_class_or'};
        else
            stdarg={stdarg{:},'mclassifier','one_class'};
        end
        R=ufsclass4(xsub,'c_algo','nbpw','fe_algo','fbcsp','fs_algo','fsmibifpw',...
            'fe_para',{2,'csparg',{'eigmethod','eig'}},'fs_para',{4},...
            'bPairCSPFeatures',true,...
            'useconfi',true,stdarg{:},...
            'filterarg',{'ftype','filtfilt'});
        switch sel_experiment
            case 0
                Results{cmethod,subi}=R; %#ok<AGROW>
                Results=cleanresults(Results); %#ok<NASGU>
                clear xsub R
                save nyghexperiment_2013_expt1_0.mat
            case 1
                AResults{cmethod,subi}=R; %#ok<AGROW>
                AResults=cleanresults(AResults); %#ok<NASGU>
                clear xsub R
                save nyghexperiment_2013_expt1_1.mat
            case 2
                TResults0{cmethod,subi}=R; %#ok<AGROW>
                %TResults0=cleanresults(TResults0); %#ok<NASGU>
                clear xsub R
                save nyghexperiment_2013_expt1_2.mat
            case 3
                ATResults0{cmethod,subi}=R; %#ok<NASGU,AGROW>
                clear xsub R
                save nyghexperiment_2013_expt1_3.mat
        end
    end
end
clear sel*