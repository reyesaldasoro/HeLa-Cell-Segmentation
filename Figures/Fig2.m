% Fig1b.m 
clear all
close all
%%
baseDir                         = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dir0            = dir (strcat(baseDir,'*.tif*'));
gaussFilt       = fspecial('Gaussian',3,1);
k               = 220;
Hela_3D         = ( imfilter(imread(strcat(baseDir,dir0((k)).name)), gaussFilt));
%%
% the slices will be subsampled (as they are 8,000 x 8,000
stepPix             = 4;
numCells            = 20;
[IndividualHelaLabels,rankCells,positionROI,helaDistFromBackground2,helaBoundary,helaBackground]   = detectNumberOfCells(Hela_3D(1:stepPix:end,1:stepPix:end),numCells);
hela2                               = double(imfilter(Hela_3D,fspecial('gaussian',5,3)));
    maxDist = max(helaDistFromBackground2(:));
%%
h131 = subplot(131);
    imagesc(hela2)

    title('(a)','fontsize',18)
    hColorbar = colorbar;
    hColorbar.Location='east';
    axis off
    
    h132 = subplot(132);
    imagesc(helaDistFromBackground2+helaBackground*maxDist/2)
    colormap gray
%     figure  
%     imagesc(hela2(1:stepPix:end,1:stepPix:end).*(1-helaBoundary))
%     for counterROI = 1:numCells
%         text(positionROI(counterROI,2),positionROI(counterROI,1),num2str(counterROI),'fontsize',20,'color','r')
%     end
%     colormap gray
%     figure
    axis off
title('(b)','fontsize',18)
    

    axis off
    
h133 = subplot(133);    
    hela3(:,:,2) = hela2(1:stepPix:end,1:stepPix:end)/255 .*(1-helaBoundary) ;
    hela3(:,:,3) = hela2(1:stepPix:end,1:stepPix:end)/255.*(1-helaBoundary)+0.8*helaBackground;
    
    
    hela3(:,:,1) = hela2(1:stepPix:end,1:stepPix:end)/255.*(1-helaBoundary) + 1*((helaDistFromBackground2/maxDist).^3)  ;
    hela3(hela3>1)=1;
    imagesc(hela3);
    for counterROI = 1:numCells
        text(positionROI(counterROI,2),positionROI(counterROI,1),num2str(counterROI),'fontsize',20,'color','r')
    end
    title('(c)','fontsize',18)
    
    axis off
%%
set(gcf,'position',[ 500  200  900  340])


hWidth = 0.31;
 h131.Position = [0.02 0.08 hWidth 0.8];
 h132.Position = [0.34 0.08 hWidth 0.8];
 h133.Position = [0.66 0.08 hWidth 0.8];
 
 
 
%% 
 print('-dpng','-r400','Fig2.png')