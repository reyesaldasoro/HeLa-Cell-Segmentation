% Fig1.m 
clear all
close all
%% Define the base directory where the data (8000x8000 slices) is stored
baseDir             = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dir0                = dir(strcat(baseDir,filesep,'*.t*'));
numFiles            = size(dir0,1);
fstep               = 8;

%%
figure
h121 = subplot(121);
hold on 
    currentImage        = imfilter(imread(strcat(baseDir,filesep,dir0(1).name)),ones(5)/25);
    [rows,cols,levs]        = size(currentImage);
    [x2d,y2d]               = meshgrid(1:rows,1:cols);
    z2d                     = ones(rows,cols);
for currentSlice        = 1:100:numFiles
    currentImage        = imfilter(imread(strcat(baseDir,filesep,dir0(currentSlice).name)),ones(5)/25);

    %     currentImage(1:currentSlice*10,:) = nan;
    startX              = 1; %currentSlice*10;
    xCoord              = x2d(startX:fstep:end,1:fstep:end);
    yCoord              = y2d(startX:fstep:end,1:fstep:end);
    zCoord              = z2d(startX:fstep:end,1:fstep:end);
    imageCoord          = currentImage(startX:fstep:end,1:fstep:end);
    hSurf = surf(xCoord,yCoord,currentSlice*zCoord,imageCoord);
    hSurf.EdgeColor='none';
end
colormap gray
axis tight
axis ij
view(45,20)
title('(a)','fontsize',18)
%%

baseDir             = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329';
dir0                = dir(strcat(baseDir,filesep,'*.t*'));
numFiles            = size(dir0,1);
fstep               = 8;
    currentImage =  (imread(strcat(baseDir,filesep,dir0(1).name)));
    [rows,cols,levs]        = size(currentImage);

caxis([50 220])
%%
currentData(rows,cols,numFiles) = 0;
for currentSlice=1:numFiles
    disp(currentSlice)
    currentData(:,:,currentSlice) =  imfilter(imread(strcat(baseDir,filesep,dir0(currentSlice).name)),ones(5)/25);
end

%%
h122 = subplot(122);
hold on
%horizontal
[x2d,y2d]               = meshgrid(1:rows,1:cols);
z2d                     = ones(rows,cols);
currentSlice            = 100;
startX                  = 1;
    xCoord              = x2d(startX:fstep:end,1:fstep:end);
    yCoord              = y2d(startX:fstep:end,1:fstep:end);
    zCoord              = z2d(startX:fstep:end,1:fstep:end);
    imageCoord          = currentData(startX:fstep:end,1:fstep:end,currentSlice);
    hSurf = surf(xCoord,yCoord,currentSlice*zCoord,imageCoord);
    hSurf.EdgeColor='none';
% vertical

x2d                     = repmat((1:rows),[numFiles 1])';
z2d                     = repmat((1:numFiles),[rows 1]);
y2d                     = ones(rows,numFiles);

fstep                   = 1;
currentSlice            = 900;
startX                  = 1;
    xCoord              = x2d(startX:fstep:end,1:fstep:end)';
    yCoord              = currentSlice*y2d(startX:fstep:end,1:fstep:end)';
    zCoord              = z2d(startX:fstep:end,1:fstep:end)';
    imageCoord          = squeeze(currentData(currentSlice,startX:fstep:end,:))';
    hSurf = surf(xCoord,yCoord,zCoord,imageCoord);
    hSurf.EdgeColor='none';




%
colormap gray
axis tight
axis ij
view(50,27)
rotate3d on
grid on
title('(b)','fontsize',18)
caxis([50 220])
set(gcf,'position',[ 500  400  900  300])
%%

 h121.Position = [0.05 0.08 0.44 0.8];
 h122.Position = [0.54 0.08 0.44 0.8];

%%
print('-dpng','-r400',filename)
