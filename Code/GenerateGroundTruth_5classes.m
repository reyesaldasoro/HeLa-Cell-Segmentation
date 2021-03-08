%% Prepare Ground Truth Hela Cell 5 classes: 
% Nucleus, Nuclear Envelope, Background, Cell, Other Cells

baseDir_data    = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329';
baseDir_GT_4c   = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_4c';

dir_data        = dir(strcat(baseDir_data,filesep,'*.t*'));
dir_GT          = dir(strcat(baseDir_GT_4c,filesep,'*.mat'));
baseDir_GT_5c   = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_5c';
baseDir_GT_5ct   = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_5c_tif';

%%
currentSlice =1;
currentData = imfilter(imread(strcat(baseDir_data,filesep,dir_data(currentSlice).name)),ones(3)/9);
currentGT   = load(strcat(baseDir_GT_4c,filesep,dir_GT(currentSlice).name));
groundTruth = currentGT.groundTruth;
composite(:,:,1) = currentData+50*uint8(groundTruth==3);
composite(:,:,2) = currentData+50*uint8(groundTruth==2);
composite(:,:,3) = currentData;
figure(1)
imagesc(composite)
    set(gca,'position',[0 0 1 1 ]);axis off
%
splitCells      = roipoly();
ownCell_L       = bwlabel(splitCells.*(groundTruth==3));
ownCell_P       = regionprops(ownCell_L,'Area');
[m1,m2]         = sort([ownCell_P.Area],'descend');
ownCell         = (ownCell_L==m2(1));
composite(:,:,1) = currentData+50*uint8(groundTruth==3);
composite(:,:,2) = currentData+50*uint8(groundTruth==2);
composite(:,:,3) = currentData-50*uint8(ownCell);
figure(1); imagesc(composite)
gt5             = uint8(groundTruth+2*ownCell.*(groundTruth==3));
figure(2); imagesc(gt5)
%
saveName = strcat(baseDir_GT_5c ,filesep,dir_GT(currentSlice).name);
groundTruth = gt5;
save(saveName, 'groundTruth');
saveNamet = strcat(baseDir_GT_5ct,filesep, dir_GT(currentSlice).name(1:end-3),'tif');

imwrite(51*gt5,saveNamet)
beep
