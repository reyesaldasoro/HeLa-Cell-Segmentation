%% Basic locations, Folder With TIFFS
baseDir             = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dirTiffs            = dir(strcat(baseDir,filesep,'*.tif*'));
numTiffs            = size(dirTiffs,1);   
%% Folder with the saved segmentations
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir1                = dir(strcat(dir0,filesep,'Hela_RO*.mat'));
numFiles            = size(dir1,1);
%% Prepare for 3D display 
load('final_coords.mat')
load(dir1(3).name)

% This is for the slices to create the surfaces 
[rows,cols,levs]        = size(Hela_nuclei);
numSlices               = levs;
[x2d,y2d]               = meshgrid(1:rows,1:cols);
z2d                     = ones(rows,cols);
zz_3D                   = zeros(rows,cols,levs);

for k=1:numSlices
    disp(k)
    zz_3D(:,:,k)        = ones(rows,cols)*k;
end
xx_3D                   = repmat(x2d,[1 1 numSlices]);
yy_3D                   = repmat(y2d,[1 1 numSlices]);
%% This is for the surface 
% We could create the surface directly with this, but as the volume is rather large,
% the number of faces of the surface would be rather high, it would be slow and may
% crash in a computer with low memory. This it is better to generate the reference
% framework to create a isosurface with fewer faces

% We can now generate the isosurface of the cell, with a certain step; using fstep =1
% would be the same as the whole surface. With 8/16, the results are still visually good
% and hard to distinguish with smaller steps.

maxSlice            = levs;
minSlice            = 1;
fstep               = 16;

%%
figure
numFiles            = size(dir1,1);
cells_to_discard = [1 6 15 27 28 29 30];  % these cells are close to the edges, discard for now

% Colours
jet2    = jet;
jet3    = jet2(round(linspace(1,256,numFiles)),:);
[a,b]   = sort(rand(numFiles,1));

for k=1:numFiles  
    % Usual issue when reading the folders 10, 11, ... 19, 2, 20 ...
    % calculate the correct order (next time, save 1 as 01, 2 as 02, etc
    q           = strfind(dir1(k).name,'_');
    currCell    = str2num(dir1(k).name(q(2)+1:q(3)-1));
    %disp(currCell)
    if ~any(intersect(currCell,cells_to_discard))
        disp(currCell)
        load(dir1(k).name);
        % ***** display all the cells as subplots with one slice ****
        %subplot(5,6,(currCell))
        %imagesc(squeeze(Hela_background(:,1000,:)+2*Hela_nuclei(:,1000,:)))
        %title(strcat(num2str(currCell),',',32,num2str(100*volumeCell(k),2),'%'),'fontsize',10)
        %title(strcat(num2str(currCell)))

        % ***** display all the cells as surfaces in one 3D plot ****       
        surf_Nuclei          = isosurface(yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)  +final_coords(k,1) ,...
                                          xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) +final_coords(k,3) ,...
                                          zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) +final_coords(k,5) ,...
                                    Hela_nuclei(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.7);
                    
        % Finally, let's display the surface, allocate random colours
        h4                  = patch(surf_Nuclei);
        %h4.FaceColor        = 'red';
        %h4.FaceColor        = 0.75*rand(1,3);
        
        h4.FaceColor        = jet3(b(k),:);
        h4.EdgeColor        = 'none';
        % keep all the handles
        handlesNuclei{currCell}=h4;
    end
    rotate3d on
end
%%
view(74,47)
 lighting('phong');
hLight1 = camlight ('left');
%hLight2 = camlight ('right');
%axis tight
grid on

%% Insert a slice!
% Read first slice
currSlice               = imfilter(imread(strcat(baseDir,filesep,dirTiffs(1).name)),ones(3)/9);
[rowsWhole,colsWhole]   = size(currSlice);
axis([1 rowsWhole 1 colsWhole 1 numTiffs])
[x2dWhole,y2dWhole]     = meshgrid(1:rowsWhole,1:colsWhole);
z2dWhole                     = ones(rowsWhole,colsWhole);
%%
hold on
fstep                   = 8;
currSliceSurf           = surf(x2dWhole(1:fstep:end,1:fstep:end),...
                               y2dWhole(1:fstep:end,1:fstep:end),...
                               z2dWhole(1:fstep:end,1:fstep:end),...
                               currSlice(1:fstep:end,1:fstep:end)','edgecolor','none');
                           
colormap gray
%% Create a video with the slices up and down
clear F
counterVideo=49;
for cSlices     = [ (numTiffs-60:-10:1)]
    disp(cSlices)
    currSlice           = imfilter(imread(strcat(baseDir,filesep,dirTiffs(cSlices).name)),ones(5)/25);
    currSliceSurf.CData = currSlice(1:fstep:end,1:fstep:end)';
    currSliceSurf.ZData = cSlices*z2dWhole(1:fstep:end,1:fstep:end);
    drawnow;
    F(counterVideo) = getframe(gcf);
    counterVideo = counterVideo+1;
end
                         
                         
%% This is to add numbers to the cells, this is optional and not always necessary
numFiles            = size(dir1,1);
for k=1:numFiles
    q=strfind(dir1(k).name,'_');
    currCell  = str2num(dir1(k).name(q(2)+1:q(3)-1));
    if ~any(intersect(currCell,cells_to_discard))
        q=strfind(dir1(k).name,'_');
        currCell  = str2num(dir1(k).name(q(2)+1:q(3)-1));
        % create the text at the middle of the volume and a few slices above
        % the edge of the cell volume
        handleText(k) = text(0.5*final_coords(currCell,1)+0.5*final_coords(currCell,2),...
                             0.5*final_coords(currCell,3)+0.5*final_coords(currCell,4),...
                             final_coords(currCell,6)+20,num2str(currCell),...
                             'Color','red','FontSize',14);
    else
        % These are the cells that were not displayed, not really necessary
        % except for analysis
        q=strfind(dir1(k).name,'_');
        currCell  = str2num(dir1(k).name(q(2)+1:q(3)-1));
        
        handleText(k) = text(0.5*final_coords(currCell,1)+0.5*final_coords(currCell,2),...
            0.5*final_coords(currCell,3)+0.5*final_coords(currCell,4),...
            final_coords(currCell,6)+50,num2str(currCell),...
            'Color','blue','FontSize',10);
        
        
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
   
 
 