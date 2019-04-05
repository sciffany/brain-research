%isub=subs(input('pls type in the no. of subject:'));
%close all;
subsToPlot = 5;
emotions = [1:6];
colours={'b';'g';'r';'k';'y';'m';};
AllNames={'amusement','fear','disgust','joy','neutral','sadness'};
Names = AllNames(emotions);
%redo the plots, show 2 x 5 plots, where each row is a 
eMap={'',   'Fp1',  '',     'Fp2',  '';...
      'F7', 'F3',   'Fz',   'F4',   'F8';...
      'FT7', 'FC3',   'FCz',   'FC4',   'FT8';...
      'T7', 'C3',   'Cz',   'C4',   'T8';...
      'TP7', 'CP3',   'CPz',   'CP4',   'TP8';...
      'P7', 'P3',   'Pz',   'P4',   'P8';...
      'O1', 'PO1',   'Oz',   'PO2',   'O2';...
      };

nRows = 7;
nCols = 5;%don't change
nPlots = nRows * nCols;
eMapNum = 1:prod(size(eMap));
eMapNum = reshape(eMapNum,[size(eMap,2) size(eMap,1)]);
eMapNum = eMapNum';


for isub=subsToPlot
    for ich=1:prod(size(eMap))
       if rem(ich,nPlots) == 1
           figure('name', ['Subject ' num2str(isub)]);
       end
       idx = eMapNum == ich;
       iRow = find(sum(idx,2));
       iCol = find(sum(idx,1));
       if isempty(eMap{iRow,iCol})
          continue;
       end
       ichannel = find(strcmp(sel_chan_list, eMap{iRow,iCol}));

       for icate=emotions
           cat = cates(icate);
           colour=colours{icate};

           if rem(ich,nPlots)==0;
               subplotIndex=nPlots;
           else
               subplotIndex=rem(ich,nPlots);
           end

           subplot(nRows,nCols, subplotIndex);
           hold on;
           pxx=ave_superCellPxx{icate,isub}(:,ichannel);
           plot(freq,(pxx),colour)
           %plot(freq,10*log10(pxx),colour)
           xlim([0,50])
           %ylim([0,4])
           %ylim([-5,15])
           title(Raw_sub.sel_chan_list{ichannel})
           xlabel('Frequency (Hz)')
           ylabel('Magnitude (dB)')
       end
    end
    legend(Names,'FontSize',6)
end

