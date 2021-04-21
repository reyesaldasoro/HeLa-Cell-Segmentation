clear all
close all

%% If folders already exist skip previous steps
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir1                = dir(strcat(dir0,filesep,'Hela_RO*'));
dir2                = dir1([dir1.isdir]);
dir3                = dir1(~[dir1.isdir]);

numFolders          = size(dir2,1);
load('final_coords.mat')

for k=1:numFolders
    listFolders{k,1} = dir2(k).name;
end
%% Iterate over all folders and visualise all volumes in one figure
step            = 32;
step2           = 8;
slicesToRead    = 1:step2:300;
numSlices       = size(slicesToRead,2);

for k=1:numFolders
    disp(k)
    currFolder  = dir2(k).name;
    currDir     = dir(strcat(dir0,filesep,currFolder,filesep,'*.tif'));
    clear currSlices
    currSlices(2000,2000,numSlices)=0;
    for k2=1:numSlices
        currSlices(:,:,k2)=(imread(strcat(dir0,filesep,currFolder,filesep,currDir(slicesToRead(k2)).name)));
    end
    %midSlice    = (imread(strcat(dir0,filesep,currFolder,filesep,currDir(200).name)));
    %imagesc(midSlice)
    %
    %currSlices(1001:2000,1001:2000,:)=0;
    %p2 = patch(isocaps(currSlices(1:16:end,1:16:end,:), 5),'FaceColor','interp','EdgeColor','none');
    currSlices2=currSlices;
    currSlices2(:,1001:2000,:)=[];
    subplot(5,6,k)
    p1 = patch(isocaps(currSlices2(1:step:end,1:step:end,:), 5),'FaceColor','interp','EdgeColor','none');
    currSlices2=currSlices;
    currSlices2(1001:2000,:,:)=[];
    p2 = patch(isocaps(currSlices2(1:step:end,1:step:end,:), 5),'FaceColor','interp','EdgeColor','none');
    colormap gray
    view(136,40)
    axis tight
    axis off
    title(strcat('(',num2str(k),')'),'fontsize',10)
    
    %
end

for k=1:numFolders
    subplot(5,6,k)
    handleAx(k)=gca;  
    axis ij
    view(45,45)
end
vertPos = 0.76:-0.19:0;%[0.8 0.6 0.4 0.2 0.0];
horPos  = 0.01:0.165:0.89;
for k=1:numFolders
    handleAx(k).Position(3:4)=[0.15 0.2];
    %  ceil([1:30]/6)  this locates the rows
    handleAx(k).Position(2) =vertPos (ceil(k/6));
    %  1+rem(-1+[1:30],6)  this locates the columns
    handleAx(k).Position(1) =horPos (1+rem(-1+k,6));
end
%%
  set(gcf,'position',[ 400  200  900  530])


%%
filename ='Fig_allROIS.png';
print('-dpng','-r300',filename)