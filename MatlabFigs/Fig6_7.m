% Fig2
clear all
close all
load('Results_ROI_1656_6756_329_2021_03_09B.mat')
baseDir_data    = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329';

%%
dir_data        = dir(strcat(baseDir_data,filesep,'*.t*'));
    current_GT2=current_GT;
    current_GT2(current_GT2==1)=1;
    current_GT2(current_GT2==3)=0;
    current_GT2(current_GT2==4)=0;
    current_GT2(current_GT2==5)=1;    
slicesToPlot = [70 115 200];
% Ground truth
for k=1:3
    currentSlice   = slicesToPlot(k);
    currentImage = imfilter(imread(strcat(baseDir_data,filesep,dir_data(currentSlice).name)),ones(5)/25);
    composite(:,:,1) = currentImage+50*uint8(current_GT(:,:,currentSlice)==5);
    composite(:,:,2) = currentImage+50*uint8(current_GT(:,:,currentSlice)==2);
    composite(:,:,3) = currentImage;
    
    % add a scale bar, since the voxels are 10 nm, 500 pixels are 5 microns
    composite(1700:1750,1400:1900,:)=0;
    
    h333(3*k-2)=subplot(3,3,3*k-2);
    imagesc(composite)
    axis off
    % set(gca,'position',[0 0 1 1 ]);axis off
end
% results
for k=1:3
    currentSlice   = slicesToPlot(k);
    currentImage = imfilter(imread(strcat(baseDir_data,filesep,dir_data(currentSlice).name)),ones(5)/25);
    
    composite(:,:,1) = currentImage+50*uint8(Hela_cell(:,:,currentSlice)-Hela_nuclei(:,:,currentSlice));
    composite(:,:,2) = currentImage+50*uint8(Hela_nuclei(:,:,currentSlice));
    composite(:,:,3) = currentImage;
    h333(3*k-1)=subplot(3,3,3*k-1);
    imagesc(composite)
    axis off
end
for k=1:3

    currentSlice   = slicesToPlot(k);
    h333(3*k)=subplot(3,3,3*k);
    imagesc(double(-Hela_cell(:,:,currentSlice)-Hela_nuclei(:,:,currentSlice))+double(current_GT2(:,:,currentSlice)))
    axis off 
end
colormap gray
%%
h333(1).Title.String='Ground Truth';
h333(2).Title.String='Segmentation';
h333(3).Title.String='Comparison ';
 h333(1).Title.FontSize=15;
 h333(2).Title.FontSize=15;
 h333(3).Title.FontSize=15;
 
set(gcf,'position',[ 100  100  800  650])
xWidth = 0.31;
yHeight = 0.29;
h333(1).Position    = [0.02    0.66    xWidth   yHeight];
h333(4).Position    = [0.02    0.34    xWidth   yHeight];
h333(7).Position    = [0.02    0.02    xWidth   yHeight];

h333(2).Position    = [0.35    0.66    xWidth   yHeight];
h333(5).Position    = [0.35    0.34    xWidth   yHeight];
h333(8).Position    = [0.35    0.02    xWidth   yHeight];

h333(3).Position    = [0.68    0.66    xWidth   yHeight];
h333(6).Position    = [0.68    0.34    xWidth   yHeight];
h333(9).Position    = [0.68    0.02    xWidth   yHeight];

%%
 cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\MatlabFigs')

filename ='Fig6_scale.png';
print('-dpng','-r300',filename)
%%  Zoom in
xx = [100.5 1300.5];
yy = [1100.5 1740.5];

h333(1).XLim=xx;
h333(2).XLim=xx;
h333(3).XLim=xx;
h333(1).YLim=yy;
h333(2).YLim=yy;
h333(3).YLim=yy;

%%
xx = [200.5 1000.5];
yy = [100.5 900.5];

h333(4).XLim=xx;
h333(5).XLim=xx;
h333(6).XLim=xx;
h333(4).YLim=yy;
h333(5).YLim=yy;
h333(6).YLim=yy;


%%

xx = [200.5 1100.5];
yy = [1100.5 1900.5];

h333(7).XLim=xx;
h333(8).XLim=xx;
h333(9).XLim=xx;
h333(7).YLim=yy;
h333(8).YLim=yy;
h333(9).YLim=yy;
%%
%%
filename ='Fig7_scale.png';
print('-dpng','-r300',filename)
