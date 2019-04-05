%get the supermatrix
for isub=1:1:5;
    for icate=171:1:176;
        supermatrix(:,:,:,icate,isub)=GetPxx(icate,isub);
    end
end
