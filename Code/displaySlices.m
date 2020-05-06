
baseDir             = 'D:\Acad\Crick\ROIs\';
dir0                = dir(strcat(baseDir,'*tiff'));

filtG= gaussF(3,3,1);


%%
numROI              = 5;
currROI             = dir0(numROI).name;
currSlice           = 90;
filtG                   = gaussF(3,3,1);
currentImage            = double(imread(strcat(baseDir,currROI),currSlice));

[nucleiHela,avNucleiIntensity,envelopeIntensity]                          = segmentNucleiHelaEM(currentImage);
[Hela_background,Background_intensity,Hela_intensity]   = segmentBackgroundHelaEM(currentImage,avNucleiIntensity,nucleiHela);
[cellRegion,dataOut]                                    = segmentHelaCellEM(Hela_background,nucleiHela,currentImage);


figure(currSlice)
imagesc(dataOut/255)
%imagesc(imfilter(currentImage,filtG))
title(strcat(currROI,32,'slice',32,num2str(currSlice)),'interpreter','none')
%%
colormap gray
figure(2)
imagesc(imfilter(currentImage,filtG))
axis([400 800 700 1100])
colormap gray
%%


figure(12)
imagesc(dataOut/255)
%%


figure(19)

imagesc(imfilter(currentImage,filtG)+watershedsBack)






%%
currentImage_e          = edge(currentImage,'canny',[],1.5);
imagesc(currentImage.*(currentImage_e==0))
axis([500 800 800 1100])
