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

h121 = subplot(121);
    imagesc(helaDistFromBackground2+helaBackground*maxDist/2)
    colormap gray
%     figure  
%     imagesc(hela2(1:stepPix:end,1:stepPix:end).*(1-helaBoundary))
%     for counterROI = 1:numCells
%         text(positionROI(counterROI,2),positionROI(counterROI,1),num2str(counterROI),'fontsize',20,'color','r')
%     end
%     colormap gray
%     figure


    title('(a)','fontsize',18)
    axis off
    
h122 = subplot(122);    
    hela3(:,:,2) = hela2(1:stepPix:end,1:stepPix:end)/255 .*(1-helaBoundary) ;
    hela3(:,:,3) = hela2(1:stepPix:end,1:stepPix:end)/255.*(1-helaBoundary)+0.2*helaBackground;
    
    
    hela3(:,:,1) = hela2(1:stepPix:end,1:stepPix:end)/255.*(1-helaBoundary) + 1*((helaDistFromBackground2/maxDist).^3)  ;
    hela3(hela3>1)=1;
    imagesc(hela3);
    for counterROI = 1:numCells
        text(positionROI(counterROI,2),positionROI(counterROI,1),num2str(counterROI),'fontsize',20,'color','r')
    end
    
    title('(b)','fontsize',18)
    axis off
%%
set(gcf,'position',[ 500  200  900  450])



 h121.Position = [0.05 0.08 0.44 0.8];
 h122.Position = [0.54 0.08 0.44 0.8];
 
 print('-dpng','-r400','Fig1b.png')