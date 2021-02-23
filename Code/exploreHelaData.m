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

%%

%%
%dir0                = 'D:\Acad\GitHub\HeLa-Cell-Segmentation\Code';
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir1                = dir(strcat(dir0,filesep,'Hela_RO*.mat'));
numFiles            = size(dir1,1);
%%
%figure
for k=9%1:numFiles
    disp(k)
    q=strfind(dir1(k).name,'_');
    currCell  = dir1(k).name(q(2)+1:q(3)-1);
    load(dir1(k).name);
    subplot(5,6,str2num(currCell))
    imagesc(squeeze(Hela_background(:,1000,:)+2*Hela_nuclei(:,1000,:)))
    title(currCell,'fontsize',10)
    volumeCell(k) = sum(sum(sum(Hela_nuclei)))/2000/2000/300;
end
%%
cells_to_discard = [1 6 15 27 28 29 30];
for k=1:numFiles
    q=strfind(dir1(k).name,'_');
    currCell  = str2num(dir1(k).name(q(2)+1:q(3)-1));
    if ~any(intersect(15,cells_to_discard))
    volumeCell2(currCell)= volumeCell(k);
    subplot(5,6,(currCell))
    title(strcat(num2str(currCell),',',32,num2str(100*volumeCell(k),2),'%'),'fontsize',10)
    end
end

%% Cells percentage of the volume:
%     1.0000    0.0364          % discard [*876*,1665,*81*]
%     2.0000    6.4039
%     3.0000    8.2434
%     4.0000    9.0499
%     5.0000    7.4914
%     6.0000    0.0094          % discard [6700,*7775*,101]
%     7.0000    6.3754
%     8.0000   11.6284
%     9.0000    8.4197
%    10.0000    7.1331
%    11.0000    6.5987
%    12.0000   14.0224
%    13.0000    9.1660
%    14.0000    5.9829
%    15.0000    0.4070          % discard [6688,*432*,241]
%    16.0000    7.7108
%    17.0000    5.6142
%    18.0000    7.9064
%    19.0000    8.1155
%    20.0000    7.8176
%    21.0000    9.6202
%    22.0000    6.9922
%    23.0000    6.7998
%    24.0000    6.5423
%    25.0000    4.7663
%    26.0000    3.4005
%    27.0000    0.0105          % discard [*7737*,*7703*,381]
%    28.0000    0.0645          % discard [7604,*465*,*421*]
%    29.0000    0.0047          % discard [6853,2802,*421*]
%    30.0000    0.8341          % discard [2051,3944,*441*]
   
   
%%
cells_to_discard = [1 6 15 27 28 29 30];
for k=1:numFiles
    q=strfind(dir1(k).name,'_');
    currCell  = str2num(dir1(k).name(q(2)+1:q(3)-1));
    if ~any(intersect(15,cells_to_discard))
    volumeCell2(currCell)= volumeCell(k);
    subplot(5,6,(currCell))
    title(strcat(num2str(currCell),',',32,num2str(100*volumeCell(k),2),'%'),'fontsize',10)
    end
end


