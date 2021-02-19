baseDir                         = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
tic;
[final_coords,final_centroid,final_cells,final_dist]        = detectNumberOfCells_3D(baseDir,20,1);
t1=toc;
%%
tic
listFolders         = generate_ROI_Hela (baseDir,final_coords,final_centroid);
t2=toc;
%%
k=1;
tic
Hela_background 	= segmentBackgroundHelaEM(listFolders{1});
Hela_nuclei     	= segmentNucleiHelaEM(Hela);    

t3=toc;