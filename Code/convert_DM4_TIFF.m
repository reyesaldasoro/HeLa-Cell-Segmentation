%% Convert all the DM4 UINT32 images to TIFF  UINT8 images to keep consistency with Crick previous formats
clear all
close all

baseDir             = 'D:\Acad\Crick\Hela8000\';
outputDir           = 'D:\Acad\Crick\Hela8000_tiff\';



dir0                = dir(strcat(baseDir,'*dm4'));

numImages           = size(dir0,1);

%%
%filtG= gaussF(3,3,1);

for k=1:numImages
    disp(k)
    [c,d]=dmread(dir0(k).name);

    % To convert from uint32 to uint8 and keep the same range of values than the cropped ROIs
    d3=double(d); 
    d4=(d3-mean(d3))/std(d3(:));
    d5=165+35*d4;
    d5(d5<0)=0;d5(d5>256)=256;    
    d6=uint8(d5);
    imwrite(d6,strcat(outputDir,'HeLa_8000_',dir0(k).name(end-7:end-4),'.tiff'));
end
    

%%
