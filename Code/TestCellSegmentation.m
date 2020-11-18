centralSlice =   239;

figure(1)
imagesc(a(:,:,centralSlice)+2*(b(:,:,centralSlice)))
figure(2)

%
cc = watershed(- imfilter(bwdist(b(:,:,centralSlice)),fspecial('Gaussian',3,1)  ));
dd = unique(cc(a(:,:,centralSlice)));
cell = (cc==dd).*(1-b(:,:,centralSlice)).*(1-a(:,:,centralSlice));
%cc = imfilter(bwdist(b(:,:,centralSlice)),fspecial('Gaussian',3,1))  ;
imagesc(a(:,:,centralSlice) +2*(b(:,:,centralSlice))  +3*(cell))


%%
centralSlice = 282;
[Hela_cell] = segmentCellHelaEM_3D(Hela_nuclei(:,:,centralSlice),Hela_background(:,:,centralSlice));
qq(:,:,1) = (Hela_3D(:,:,centralSlice)+ 20*Hela_cell)  /255;
qq(:,:,2) = (Hela_3D(:,:,centralSlice)+ 30*Hela_nuclei(:,:,centralSlice))  /255;
qq(:,:,3) = (Hela_3D(:,:,centralSlice)+ 100*Hela_background(:,:,centralSlice))/255;
figure(4)
imagesc(qq)

%%

segmentCellHelaEM_3D(Hela_nuclei(:,:,centralSlice),Hela_background(:,:,centralSlice));