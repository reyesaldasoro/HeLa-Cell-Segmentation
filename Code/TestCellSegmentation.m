% centralSlice =   239;
% 
% figure(1)
% imagesc(a(:,:,centralSlice)+2*(b(:,:,centralSlice)))
% figure(2)
% 
% %
% cc = watershed(- imfilter(bwdist(b(:,:,centralSlice)),fspecial('Gaussian',3,1)  ));
% dd = unique(cc(a(:,:,centralSlice)));
% cell = (cc==dd).*(1-b(:,:,centralSlice)).*(1-a(:,:,centralSlice));
% %cc = imfilter(bwdist(b(:,:,centralSlice)),fspecial('Gaussian',3,1))  ;
% imagesc(a(:,:,centralSlice) +2*(b(:,:,centralSlice))  +3*(cell))

baseDir                         = 'C:\Users\sbbk034\Documents\Acad\Crick\ROIs\ROI_1656-6756-329\';
% multiple images
dir0                            = dir (strcat(baseDir,'*.tif*'));
numSlices                       = size(dir0,1);
Hela_3D(2000,2000,numSlices)    = 0;
gaussFilt                       =  fspecial('Gaussian',3,1);
for k=1:numSlices
    disp(strcat('Reading slice number',32,num2str(k)))
    Hela_3D(:,:,k)              = imfilter(imread(strcat(baseDir,dir0(k).name)), gaussFilt);
end
clear k dir0 baseDir gaussFilt
%% Calculate or read
%[Hela_nuclei,Hela_background]   = segmentNucleiHelaEM_3D(Hela_3D);

load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_background.mat');
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_nuclei.mat');
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_cell.mat');

%% This works well whilst there is a nuclei, beyond that is not that good,
% perhaps propagate surfaces down or get a vertical cut
centralSlice = 126;
%[Hela_cell(:,:,centralSlice)] = segmentCellHelaEM_3D(Hela_nuclei(:,:,centralSlice),Hela_background(:,:,centralSlice));

qq(:,:,1) = (Hela_3D(:,:,centralSlice)+ 20*Hela_cell2(:,:,centralSlice))  /255;
qq(:,:,2) = (Hela_3D(:,:,centralSlice)+ 30*Hela_nuclei(:,:,centralSlice))  /255;
qq(:,:,3) = (Hela_3D(:,:,centralSlice)+ 100*Hela_background(:,:,centralSlice))/255;
figure(1)
imagesc(qq)

%%




segmentCellHelaEM_3D(Hela_nuclei(:,:,centralSlice),Hela_background(:,:,centralSlice));