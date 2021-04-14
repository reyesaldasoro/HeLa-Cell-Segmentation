% Fig3.m
clear all
close all

cd ('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code')

baseDirTiff = ('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_ROI_23_30_6816_1601_341\');
dir0        = dir(strcat(baseDirTiff,'*.tif'));
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_ROI_23_30_6816_1601_341_Nuclei.mat');

%%

% central slice
%currSlide = 108;
% higher up slice with bigger gaps
%currSlide = 193;

%imagesc(Hela_steps(:,:,4)+Hela_steps(:,:,5)+3*(Hela_background(:,:,currSlide)))
%%
%
slides=[40 50 70 100 120 180 210 240];
figure
fSize =18;
set(gcf,'position',[ 500  200  900  450])
for k=1:8
    currSlide = slides(k);% 0+30*k;

    currImage = imfilter(imread(strcat(baseDirTiff,dir0(currSlide).name)),ones(5)/25);

    [Hela_cell,Hela_steps] = segmentCellHelaEM_3D(Hela_nuclei(:,:,currSlide),Hela_background(:,:,currSlide));

    
    h{k}                = subplot(2,4,k);
    composite(:,:,3) = currImage;%-50*uint8(1-Hela_background(:,:,currSlide));
    composite(:,:,1) = currImage+70*uint8(Hela_steps(:,:,5));
    composite(:,:,2) = currImage;
    imagesc(composite)
    h{k}.Title.FontSize     = fSize;
    h{k}.XTick=[];h{k}.YTick=[];
    h{k}.Title.String       = num2str(currSlide);

end



%
aWidth = 0.23; aHeight = 0.41;
aShift = 0.24;
h{1}.Position = [0.025+0*aShift 0.52  aWidth aHeight];
h{2}.Position = [0.025+1*aShift 0.52  aWidth aHeight];
h{3}.Position = [0.025+2*aShift 0.52  aWidth aHeight];
h{4}.Position = [0.025+3*aShift 0.52  aWidth aHeight];
h{5}.Position = [0.025+0*aShift 0.02 aWidth aHeight];
h{6}.Position = [0.025+1*aShift 0.02 aWidth aHeight];
h{7}.Position = [0.025+2*aShift 0.02 aWidth aHeight];
h{8}.Position = [0.025+3*aShift 0.02 aWidth aHeight];
%%


h241.Title.String       = '(a)';
h242.Title.String       = '(b)';
h243.Title.String       = '(c)';
h244.Title.String       = '(d)';
h245.Title.String       = '(e)';
h246.Title.String       = '(f)';
h247.Title.String       = '(g)';
h248.Title.String       = '(h)';
 %%
  print('-dpng','-r400','Fig4_211.png')