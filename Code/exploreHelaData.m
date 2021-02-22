baseDir             = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir1                = dir(strcat(dir0,filesep,'Hela_RO*'));
%%

dir2                = dir1([dir1.isdir]);
numFolders          = size(dir2,1);

for k=1:numFolders
    listFolders{k} = dir2(k).name;
end


%%
k2=7;
dir3 = dir(strcat(dir2(k2).name,filesep,'R*'));
numFiles            = size(dir3,1);
Hela(2000,2000,300) = 0;
for k=1:numFiles
    disp(k)
    Hela(:,:,k) = imread(strcat(dir2(k2).name,filesep,dir3(k).name));
end

%%
figure(k2)
imagesc(squeeze(Hela(1:4:end,1750,:)))
colormap gray

%%
k=100;
imagesc(Hela_nuclei(:,:,k)+2*Hela_background(:,:,k))