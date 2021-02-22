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
%%
for k=2:numFolders
    tic
    [Hela_nuclei,Hela_background]     	= segmentNucleiHelaEM_3D(listFolders{k});
    %[Hela_cell]                         = segmentCellHelaEM_3D(Hela_nuclei,Hela_background);
    %Hela_cell                           = Hela_cell>0.5;
    saveName                            = strcat(listFolders{k},'_Nuclei');
    %save(saveName, 'Hela_nuclei', 'Hela_background','Hela_cell');
    save(saveName, 'Hela_nuclei', 'Hela_background');
    t3(k)=toc;
end

