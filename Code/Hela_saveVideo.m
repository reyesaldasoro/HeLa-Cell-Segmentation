
%% Define the ROI (Alienware)
baseDir     = 'C:\Users\sbbk034\Documents\Acad\Crick\ROIs\ROI_1656-6756-329\';
dir0        = dir (strcat(baseDir,'*.tiff'));
numFiles    = size(dir0,1); 
%% Read all the slices of one ROI
% These are read pretty quickly and it is very large to store
Hela_3D(2000,2000,numFiles)=0;
gaussFilt =  fspecial('Gaussian',3,1);
for k=1:numFiles
    disp(k)
    Hela_3D(:,:,k) = imfilter(imread(strcat(baseDir,dir0(k).name)), gaussFilt);
end

%% Read previous segmentations

%[Hela_nuclei,Hela_background]   = segmentNucleiHelaEM_3D(Hela_3D);

load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_background.mat');
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_nuclei.mat');
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_cell4.mat');


%% Display a video
figure(11)
clear F
[rows,cols,levs]        = size(Hela_cell);

for currentSlice=1:levs
    qq(:,:,1) = (Hela_3D(:,:,currentSlice)+ 20*Hela_cell(:,:,currentSlice))  /255;
    qq(:,:,2) = (Hela_3D(:,:,currentSlice)+ 30*Hela_nuclei(:,:,currentSlice))  /255;
    qq(:,:,3) = (Hela_3D(:,:,currentSlice)+ 100*Hela_background(:,:,currentSlice))/255;
    %pause(0.1)
    imagesc(qq)
    title(strcat('Slice:',32,num2str(currentSlice)))
    F(currentSlice)=getframe;
end
centralSlice = round(levs/2);
%%
 %% Save the movie as MPEG 
            v = VideoWriter('Hela_cell_nucleus', 'MPEG-4');
            open(v);
            writeVideo(v,F);
            close(v);
    %% save the movie as a GIF
    [imGif,mapGif] = rgb2ind(F(centralSlice).cdata,256,'nodither');
    numFrames = size(F,2);

    imGif(1,1,1,numFrames) = 0;
    for k = 2:numFrames 
      imGif(:,:,1,k) = rgb2ind(F(k).cdata,mapGif,'nodither');
    end
    %%

    imwrite(imGif,mapGif,'Hela_cell_nucleus.gif',...
            'DelayTime',0,'LoopCount',inf) %g443800