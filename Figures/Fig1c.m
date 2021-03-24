% Fig1c.m 
clear all
close all

%% Define the base directory where the data (8000x8000 slices) is stored
baseDir                         = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';

%% Detect the number of cells to be segmented, record centroids and coordinates
% Currently all ROIs are forced to be 2,000 x 2,000 x 300 This may not
% always be the best as the centroid may be far from the centre of the ROI,
% if it is above/below slice 150 the segmentation may not be well
% performed. 
tic;
[final_coords,final_centroid,final_cells,final_dist,positionROI2]        = detectNumberOfCells_3D(baseDir,20);
t1=toc;

%%
gaussFilt       = fspecial('Gaussian',3,1);

dir0                = dir(strcat(baseDir,filesep,'*.t*'));
numFiles            = size(dir0,1);
fstep               = 8;

sliceToRead               = 1;
Hela_3D         = ( imfilter(imread(strcat(baseDir,dir0((sliceToRead)).name)), gaussFilt));
    [rows,cols,levs]        = size(Hela_3D);
    [x2d,y2d]               = meshgrid(1:rows,1:cols);
    z2d                     = ones(rows,cols);
        fstep               = 8;
    %%

    figure
    h121=subplot(121);
hold on    
        startX              = 1; %currentSlice*10;
    xCoord              = x2d(startX:fstep:end,1:fstep:end);
    yCoord              = y2d(startX:fstep:end,1:fstep:end);
    zCoord              = z2d(startX:fstep:end,1:fstep:end);
    imageCoord          = Hela_3D(startX:fstep:end,1:fstep:end);
    hSurf = surf(xCoord,yCoord,sliceToRead*zCoord,imageCoord);
    hSurf.EdgeColor='none';
    axis tight
    
    
    %
    
       hold on
    numSlicesProb   = size(positionROI2,3);
    numCells        = size(positionROI2,1);
    for k=1:numSlicesProb
        for kk=1:numCells
            %        text(positionROI(kk,2,k),positionROI(kk,1,k),k,num2str(kk+(k-1)*numCells),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb])
            text(positionROI2(kk,2,k),positionROI2(kk,1,k),k,num2str(kk),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb],'fontsize',8)
        end
    end
    
    axis([1 rows 1 cols 1 numSlicesProb])
    grid on
    axis ij
    rotate3d on
    colormap gray
    %
    numFinalCells = size(final_cells,1);
    %currLine =[];
    for k=1:numFinalCells
        levsToPlot = find(final_cells(k,:));
        cellsToPlot = final_cells(k,levsToPlot);
        clear currLine
        currLine =[];
        for k2 =1:numel(levsToPlot)
            currLine = [currLine;[positionROI2(cellsToPlot(k2),:,levsToPlot(k2)) levsToPlot(k2) ]];
        end
        plot3(currLine(:,2),currLine(:,1),currLine(:,3),'linewidth',2)
    end
        title('(a)','fontsize',18)
   %%
      h122=subplot(122);
hold on    
        startX              = 1; %currentSlice*10;
    xCoord              = x2d(startX:fstep:end,1:fstep:end);
    yCoord              = y2d(startX:fstep:end,1:fstep:end);
    zCoord              = z2d(startX:fstep:end,1:fstep:end);
    imageCoord          = Hela_3D(startX:fstep:end,1:fstep:end);
    hSurf = surf(xCoord,yCoord,sliceToRead*zCoord,imageCoord);
    hSurf.EdgeColor='none';
    axis tight
    



    
       hold on
    numSlicesProb   = size(positionROI2,3);
    numCells        = size(positionROI2,1);
    for k=1:numSlicesProb
        for kk=1:numCells
            %        text(positionROI(kk,2,k),positionROI(kk,1,k),k,num2str(kk+(k-1)*numCells),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb])
            text(positionROI2(kk,2,k),positionROI2(kk,1,k),k,num2str(kk),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb],'fontsize',8)
        end
    end
    
    axis([1 rows 1 cols 1 numSlicesProb])
    grid on
    axis ij
    rotate3d on
    colormap gray
    %
    numFinalCells = size(final_cells,1);
    %currLine =[];
    for k=1:numFinalCells
        levsToPlot = find(final_cells(k,:));
        cellsToPlot = final_cells(k,levsToPlot);
        clear currLine
        currLine =[];
        for k2 =1:numel(levsToPlot)
            currLine = [currLine;[positionROI2(cellsToPlot(k2),:,levsToPlot(k2)) levsToPlot(k2) ]];
        end
        plot3(currLine(:,2),currLine(:,1),currLine(:,3),'linewidth',2)
    end 
        title('(b)','fontsize',18)
        
%%
h121.ZTickLabel=h121.ZTick*20;
h122.ZTickLabel=h121.ZTick*20;
set(gcf,'position',[ 500  200  900  450])

h121.View = [-10 80];
h122.View = [15 20];


 h121.Position = [0.05 0.08 0.44 0.8];
 h122.Position = [0.54 0.08 0.44 0.8];
 
 %%
  print('-dpng','-r400','Fig1c.png')