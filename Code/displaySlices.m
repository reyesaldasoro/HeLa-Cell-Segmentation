
baseDir             = 'D:\Acad\Crick\ROIs\';
dir0                = dir(strcat(baseDir,'*tiff'));

filtG= gaussF(3,3,1);


%%
numROI              = 21;
currROI             = dir0(numROI).name;
currSlice           = 37;
filtG= gaussF(3,3,1);
currentImage = double(imread(strcat(baseDir,currROI),currSlice));
figure(1)
imagesc(imfilter(currentImage,filtG))
title(strcat(currROI,32,'slice',32,num2str(currSlice)),'interpreter','none')
colormap gray
figure(2)
imagesc(imfilter(currentImage,filtG))
axis([400 800 700 1100])
colormap gray
%%
figure(13)

[nucleiHela,avNucleiIntensity]                             = segmentNucleiHelaEM(currentImage);
[Hela_background,Background_intensity,Hela_intensity] = segmentBackgroundHelaEM(currentImage,avNucleiIntensity);

dataOut = imfilter(currentImage,filtG);
dataOut(:,:,3) = (1-Hela_background).*imfilter(currentImage,filtG);
dataOut(:,:,2) = (1-nucleiHela).*imfilter(currentImage,filtG);
imagesc(dataOut/255)


%%
currentImage_e          = edge(currentImage,'canny',[],1.5);
imagesc(currentImage.*(currentImage_e==0))
axis([500 800 800 1100])
