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
[final_coords,final_centroid,final_cells,final_dist]        = detectNumberOfCells_3D(baseDir,20,0);
t1=toc;




%% With the coordinates previously determined generate the ROIs, 
% Crop the 8000 slices to 2000 and save in separate folders
tic
listFolders         = generate_ROI_Hela (baseDir,final_coords,final_centroid);
numFolders          = size(listFolders,1);
t2=toc;

%% Determine if the cells are too close to the edge.

margin = 700;
MarginFromEdge=[(1:size(final_centroid,1))' ...
      (final_centroid(:,1)).*(final_centroid(:,1)<margin)+ (8192-final_centroid(:,1)).*(final_centroid(:,1)>(8192-margin)) ...
      (final_centroid(:,2)).*(final_centroid(:,2)<margin)+ (8192-final_centroid(:,2)).*(final_centroid(:,2)>(8192-margin))...
      (final_centroid(:,3)).*(final_centroid(:,3)<100)+ ...
      (-final_centroid(:,3)+518).*(final_centroid(:,3)>410)];


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
for k=1:numFolders
    disp(k)
    currFolder  = dir2(k).name;
    currDir     = dir(strcat(dir0,filesep,currFolder,filesep,'*.tif'));
    clear currSlices
    currSlices(2000,2000,300)=0;
    for k2=1:300
        currSlices(:,:,k2)=(imread(strcat(dir0,filesep,currFolder,filesep,currDir(k2).name)));
    end
    %midSlice    = (imread(strcat(dir0,filesep,currFolder,filesep,currDir(200).name)));
    %imagesc(midSlice)
    %
    %currSlices(1001:2000,1001:2000,:)=0;
    %p2 = patch(isocaps(currSlices(1:16:end,1:16:end,:), 5),'FaceColor','interp','EdgeColor','none');
    currSlices2=currSlices;
    currSlices2(:,1001:2000,:)=[];
    subplot(5,6,k)
    p1 = patch(isocaps(currSlices2(1:16:end,1:16:end,:), 5),'FaceColor','interp','EdgeColor','none');
    currSlices2=currSlices;
    currSlices2(1001:2000,:,:)=[];
    p2 = patch(isocaps(currSlices2(1:16:end,1:16:end,:), 5),'FaceColor','interp','EdgeColor','none');
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
filename ='Fig_allROIS.png';
print('-dpng','-r300',filename)


%% Iterate over all folders to extract Nuclei and Background, store as one file
for k=[20]  %1:numFolders
    tic
    [Hela_nuclei,Hela_background]     	= segmentNucleiHelaEM_3D(listFolders{k},(final_centroid(k,3)-final_coords(k,5)));
    t3(k)=toc;tic
    [Hela_cell]                         = segmentCellHelaEM_3D(Hela_nuclei,Hela_background,[],(final_centroid(k,3)-final_coords(k,5)));
    %Hela_cell                           = Hela_cell>0.5;
    %saveName                            = strcat(dir_nuclei(k).name(1:end-11),'_Cell');
    t4(k)=toc;
end
%%
saveName                            = strcat(listFolders{k},'_Nuclei');
save(saveName, 'Hela_nuclei', 'Hela_background');
saveName                            = strcat(listFolders{k},'_Cell');
save(saveName, 'Hela_cell');
  
%% Iterate over all folders to extract the cell
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
% dir1                = dir(strcat(dir0,filesep,'Hela_RO*'));
% dir2                = dir1([dir1.isdir]);
% dir3                = dir1(~[dir1.isdir]);
dir_nuclei          = dir(strcat(dir0,filesep,'Hela_RO*_Nu*.mat'));
dir_cell            = dir(strcat(dir0,filesep,'Hela_RO*_Ce*.mat'));

numFolders          = size(dir_nuclei,1);

% for k=1:numFolders
%     listFolders{k,1} = dir2(k).name;
% end
%%
for k=1:numFolders
    % These cells have been removed from the drive, process all
    %cells_to_discard = [1 6 15 27 28 29 30];
    
    tic
    %if ~any(intersect(k,cells_to_discard))
        disp(dir_nuclei(k).name)
        load(dir_nuclei(k).name);
        %imagesc(squeeze(Hela_background(:,1000,:)+2*Hela_nuclei(:,1000,:)))
        
        [Hela_cell]                         = segmentCellHelaEM_3D(Hela_nuclei,Hela_background,[],final_centroid(k,3));
        %Hela_cell                           = Hela_cell>0.5;
        %saveName                            = strcat(dir_nuclei(k).name(1:end-11),'_Cell');
        saveName                            = strcat(listFolders{k},'_Cell');
        
        save(saveName, 'Hela_cell');
        t4(k)=toc;
    %end
end

