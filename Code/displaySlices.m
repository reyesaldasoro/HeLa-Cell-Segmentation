
baseDir             = 'D:\Acad\Crick\ROIs\';
dir0                = dir(strcat(baseDir,'*tiff'));

filtG= gaussF(3,3,1);


%%
numROI              = 2;
currROI             = dir0(numROI).name;
currSlice           = 142;
filtG= gaussF(3,3,1);
currentImage = double(imread(strcat(baseDir,currROI),currSlice));

[nucleiHela,avNucleiIntensity]                          = segmentNucleiHelaEM(currentImage);
[Hela_background,Background_intensity,Hela_intensity]   = segmentBackgroundHelaEM(currentImage,avNucleiIntensity,nucleiHela);


distFromBack        = (bwdist(Hela_background));
distFromNucl        = (bwdist(nucleiHela));
breakDistFromBack   = (watershed(-imfilter(distFromBack,gaussF(19,19,1))));
watershedsBack      = 1*imdilate((breakDistFromBack==0),ones(5));
regionsNotBackground= (bwlabel((1-watershedsBack).*(1-Hela_background)));
cellRegionClass     = unique(regionsNotBackground(nucleiHela>0));
cellRegionClass(cellRegionClass==0)=[];
cellRegion          = imclose(ismember(regionsNotBackground,cellRegionClass),ones(20));


dataOut = imfilter(currentImage,filtG);
dataOut(:,:,3) = (cellRegion).*imfilter(currentImage,filtG);
dataOut(:,:,2) = (1-nucleiHela).*imfilter(currentImage,filtG);


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
