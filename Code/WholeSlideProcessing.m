%% Define the base directory where the data (8000x8000 slices) is stored
baseDir                         = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';

%% Detect the number of cells to be segmented, record centroids and coordinates
% Currently all ROIs are forced to be 2,000 x 2,000 x 300 This may not
% always be the best as the centroid may be far from the centre of the ROI,
% if it is above/below slice 150 the segmentation may not be well
% performed. 
tic;
[final_coords,final_centroid,final_cells,final_dist]        = detectNumberOfCells_3D(baseDir,20,1);
t1=toc;
%% With the coordinates previously determined generate the ROIs, 
% Crop the 8000 slices to 2000 and save in separate folders
tic
listFolders         = generate_ROI_Hela (baseDir,final_coords,final_centroid);
numFolders          = size(listFolders,1);
t2=toc;
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

%% Iterate over all folders to extract Nuclei and Background, store as one file
for k=[19 21 25 26]  %1:numFolders
    tic
    [Hela_nuclei,Hela_background]     	= segmentNucleiHelaEM_3D(listFolders{k});
    saveName                            = strcat(listFolders{k},'_Nuclei');
    save(saveName, 'Hela_nuclei', 'Hela_background');
    t3(k)=toc;
end
%% Iterate over all folders to extract the cell
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir1                = dir(strcat(dir0,filesep,'Hela_RO*'));
dir2                = dir1([dir1.isdir]);
dir3                = dir1(~[dir1.isdir]);

numFolders          = size(dir2,1);

for k=1:numFolders
    listFolders{k,1} = dir2(k).name;
end
%%
for k=3:numFolders
    cells_to_discard = [1 6 15 27 28 29 30];
    tic
    if ~any(intersect(k,cells_to_discard))
        load(dir3(k).name);
        %imagesc(squeeze(Hela_background(:,1000,:)+2*Hela_nuclei(:,1000,:)))
        
        [Hela_cell]                         = segmentCellHelaEM_3D(Hela_nuclei,Hela_background);
        %Hela_cell                           = Hela_cell>0.5;
        saveName                            = strcat(listFolders{k},'_Cell');
        save(saveName, 'Hela_cell');
        t4(k)=toc;
    end
end

