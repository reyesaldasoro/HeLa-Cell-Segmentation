% Fig3.m
clear all
close all

cd ('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code')

baseDirTiff = ('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_ROI_23_30_6816_1601_341\');
dir0        = dir(strcat(baseDirTiff,'*.tif'));
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_ROI_23_30_6816_1601_341_Nuclei.mat');

%%

% central slice
currSlide = 108;
% higher up slice with bigger gaps
%currSlide = 193;
%currSlide = 241;

currImage = imfilter(imread(strcat(baseDirTiff,dir0(currSlide).name)),ones(5)/25);


%

[Hela_cell,Hela_steps] = segmentCellHelaEM_3D(Hela_nuclei(:,:,currSlide),Hela_background(:,:,currSlide));

%imagesc(Hela_steps(:,:,4)+Hela_steps(:,:,5)+3*(Hela_background(:,:,currSlide)))
%%
%
figure
h241                = subplot(241);
currImage(1800:1900,1400:1900)=0;

imagesc(currImage);
colormap gray
h242                = subplot(242);

imagesc(Hela_nuclei(:,:,currSlide)+2*Hela_background(:,:,currSlide))
h243                = subplot(243);
imagesc(Hela_steps(:,:,1))
h244                = subplot(244);
imagesc(Hela_steps(:,:,2).*(imerode(Hela_steps(:,:,2)>0,ones(9))))

h245                = subplot(245);
imagesc(Hela_steps(:,:,3))
h246                = subplot(246);
imagesc(Hela_steps(:,:,4))

h247                = subplot(247);
imagesc(Hela_steps(:,:,4)+Hela_steps(:,:,5))

h248                = subplot(248);

imagesc(Hela_steps(:,:,5)+2*(Hela_background(:,:,currSlide).*(1-Hela_steps(:,:,5))))

%%
fSize =18;
set(gcf,'position',[ 500  200  900  450])

h241.Title.String       = '(a)';
h242.Title.String       = '(b)';
h243.Title.String       = '(c)';
h244.Title.String       = '(d)';
h245.Title.String       = '(e)';
h246.Title.String       = '(f)';
h247.Title.String       = '(g)';
h248.Title.String       = '(h)';
h241.Title.FontSize     = fSize;
h242.Title.FontSize     = fSize;
h243.Title.FontSize     = fSize;
h244.Title.FontSize     = fSize;
h245.Title.FontSize     = fSize;
h246.Title.FontSize     = fSize;
h247.Title.FontSize     = fSize;
h248.Title.FontSize     = fSize;
h241.XTick=[];h241.YTick=[];
h242.XTick=[];h242.YTick=[];
h243.XTick=[];h243.YTick=[];
h244.XTick=[];h244.YTick=[];
h245.XTick=[];h245.YTick=[];
h246.XTick=[];h246.YTick=[];
h247.XTick=[];h247.YTick=[];
h248.XTick=[];h248.YTick=[];
%%
aWidth = 0.23; aHeight = 0.41;
aShift = 0.24;
h241.Position = [0.025+0*aShift 0.52  aWidth aHeight];
h242.Position = [0.025+1*aShift 0.52  aWidth aHeight];
h243.Position = [0.025+2*aShift 0.52  aWidth aHeight];
h244.Position = [0.025+3*aShift 0.52  aWidth aHeight];
h245.Position = [0.025+0*aShift 0.02 aWidth aHeight];
h246.Position = [0.025+1*aShift 0.02 aWidth aHeight];
h247.Position = [0.025+2*aShift 0.02 aWidth aHeight];
h248.Position = [0.025+3*aShift 0.02 aWidth aHeight];

 %%
 cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\MatlabFigs')

  print('-dpng','-r400','Fig4_scale.png')