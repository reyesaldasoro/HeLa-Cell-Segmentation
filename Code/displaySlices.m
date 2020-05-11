
baseDir             = 'D:\Acad\Crick\ROIs\';
dir0                = dir(strcat(baseDir,'*tiff'));

filtG= gaussF(3,3,1);


%%
numROI              = 5;
currROI             = dir0(numROI).name;
currSlice           = 90;
filtG                   = gaussF(3,3,1);
currentImage            = double(imread(strcat(baseDir,currROI),currSlice));

[nucleiHela,avNucleiIntensity,envelopeIntensity]        = segmentNucleiHelaEM(currentImage);
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


%%
baseDir             = 'D:\Acad\Crick\Hela8000\';
dir0                = dir(strcat(baseDir,'*dm4'));

filtG= gaussF(3,3,1);

for k=10:10:500
    disp(k)
    [c,d]=dmread(dir0(k).name);
    maxD(k/10)=max(d(:));
    minD(k/10)=min(d(:));
    
end
    

%%
% To convert from uint32 to uint8 and keep the same range of values than the cropped ROIs
 d3=double(d2); 
 d4=(d3-mean(d3))/std(d3(:));
 d5=165+35*d4;
 d5(d5<0)=0;d5(d5>256)=256;
