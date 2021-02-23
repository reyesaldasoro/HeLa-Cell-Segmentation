%% Define the base directory where the data (8000x8000 slices) is stored
baseDir                         = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
tic;
[final_coords,final_centroid,final_cells,final_dist]        = detectNumberOfCells_3D(baseDir,20,1);
t1=toc;
%
tic
listFolders         = generate_ROI_Hela (baseDir,final_coords,final_centroid);
numFolders          = size(listFolders,1);
t2=toc;
%% If folders already exist
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir1                = dir(strcat(dir0,filesep,'Hela_RO*'));
dir2                = dir1([dir1.isdir]);
numFolders          = size(dir2,1);

for k=1:numFolders
    listFolders{k,1} = dir2(k).name;
end




%%
for k=17  %1:numFolders
    tic
    [Hela_nuclei,Hela_background]     	= segmentNucleiHelaEM_3D(listFolders{k});
    %[Hela_cell]                         = segmentCellHelaEM_3D(Hela_nuclei,Hela_background);
    %Hela_cell                           = Hela_cell>0.5;
    saveName                            = strcat(listFolders{k},'_Nuclei');
    %save(saveName, 'Hela_nuclei', 'Hela_background','Hela_cell');
    save(saveName, 'Hela_nuclei', 'Hela_background');
    t3(k)=toc;
end

