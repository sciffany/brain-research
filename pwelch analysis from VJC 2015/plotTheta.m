Subjects={'T','XM','XJ','YH','ZY'};
Names={'amuse','fear','disg','joy','neu','sad'};
CateNo=[171 172 173 174 175 176];
NameLabel=cell(6,1);
for icate=1:length(cates)
    cat = cates(icate); 
    index=lookupTable(CateNo,Names,cat);
    NameLabel{icate}=Names{index};
end
for ichannel=1:size(superCellAlphaPower{1,1},2)
    if rem(ichannel,8)==1;
        figure
    end
    power_alpha=nan(6,5);
    for icate=1:length(cates)
        cat = cates(icate);
        Name=Names{icate};
        subBarIndex=1:2:9;
        for isub=1:5
            power_alpha(icate,isub)=mean(superCellAlphaPower{icate,isub}(:,ichannel));
        end
        
    end
    if rem(ichannel,8)==0;
        subplotIndex=8;
        
    else
        subplotIndex=rem(ichannel,8);
    end
    
    subplot(2,4, subplotIndex);
    bar(power_alpha')
    set(gca, 'XTickLabel',Subjects);
    ylabel('alpha power')
    title(Raw_sub.sel_chan_list{ichannel})
    if rem(ichannel,8)==0;
    legend( NameLabel,'FontSize',6)
    end
    if isub==5&&icate==3&&ichannel==11;
        ylim([0 30]);
    end
    
end