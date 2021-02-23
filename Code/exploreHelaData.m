baseDir             = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir1                = dir(strcat(dir0,filesep,'Hela_RO*'));
%%

dir2                = dir1([dir1.isdir]);
numFolders          = size(dir2,1);

for k=1:numFolders
    listFolders{k,1} = dir2(k).name;
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
%% Prepare for 3D display 
% This is for the slices:

[rows,cols,levs]        = size(Hela_nuclei);
numFiles = levs;
[x2d,y2d]               = meshgrid(1:rows,1:cols);
z2d                     = ones(rows,cols);
zz_3D = zeros(rows,cols,levs);
for k=1:numFiles
    disp(k)
    zz_3D(:,:,k)        = ones(rows,cols)*k;
end
xx_3D                   = repmat(x2d,[1 1 numFiles]);
yy_3D                   = repmat(y2d,[1 1 numFiles]);
%% This is for the surface 
% We could create the surface directly with this, but as the volume is rather large,
% the number of faces of the surface would be rather high, it would be slow and may
% crash in a computer with low memory. This it is better to generate the reference
% framework to create a isosurface with fewer faces

% We can now generate the isosurface of the cell, with a certain step; using fstep =1
% would be the same as the whole surface. With 8, the results are still visually good
% and hard to distinguish with smaller steps.

maxSlice            = levs;
minSlice            = 1;
fstep               = 16;
%%
figure
cells_to_discard = [1 6 15 27 28 29 30];
for k=1:numFiles
   
    q=strfind(dir1(k).name,'_');
    currCell  = str2num(dir1(k).name(q(2)+1:q(3)-1));
    if ~any(intersect(currCell,cells_to_discard))
         disp(currCell)
        load(dir1(k).name);
        %subplot(5,6,(currCell))
        %imagesc(squeeze(Hela_background(:,1000,:)+2*Hela_nuclei(:,1000,:)))
        
        if (currCell==12)|(currCell==20)
            %Hela_nuclei         = Hela_nuclei.*(1-imdilate(Hela_background,ones(39,39,23))) ;
            Hela_nuclei         = smooth3(Hela_nuclei);
        end
        surf_Nuclei         = isosurface(xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) +final_coords(currCell,1) ,...
                                          yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) +final_coords(currCell,3) ,...
                                          zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) +final_coords(currCell,5) ,...
                                    Hela_nuclei(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.7);
                    
        % Finally, let's display the surface
        h4 =  patch(surf_Nuclei);
        h4.FaceColor=0.75*rand(1,3);
%        set(h4,'facecolor','red')
        set(h4,'edgecolor','none')       
        %title(strcat(num2str(currCell),',',32,num2str(100*volumeCell(k),2),'%'),'fontsize',10)
    end
end
%%
        view(398,43)
        lighting phong
        %camlight left
        camlight right
        axis tight


