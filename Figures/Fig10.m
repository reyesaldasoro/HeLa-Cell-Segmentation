%Fig 4
clear all
close all

%% Basic locations, Folder With TIFFS
baseDir             = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dirTiffs            = dir(strcat(baseDir,filesep,'*.tif*'));
numTiffs            = size(dirTiffs,1);   
%% Folder with the saved segmentations
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir_nuclei          = dir(strcat(dir0,filesep,'Hela_RO*_Nu*.mat'));
dir_cell            = dir(strcat(dir0,filesep,'Hela_RO*_Ce*.mat'));
numFiles_nuc        = size(dir_nuclei,1);
numFiles_cell       = size(dir_cell,1);

%% Prepare for 3D display 
load('final_coords.mat')
load(dir_nuclei(3).name)
%%
% This is for the slices to create the surfaces 
[rows,cols,levs]        = size(Hela_nuclei);
numSlices               = levs;
[x2d,y2d]               = meshgrid(1:rows,1:cols);
z2d                     = ones(rows,cols);
xx_3D                   = zeros(rows,cols,levs);
yy_3D                   = zeros(rows,cols,levs);
zz_3D                   = zeros(rows,cols,levs);

for k=1:numSlices
    disp(k)
    zz_3D(:,:,k)        = ones(rows,cols)*k;
    xx_3D(:,:,k)        = x2d;
    yy_3D(:,:,k)        = y2d;    
end
%xx_3D                   = repmat(x2d,[1 1 numSlices]);
%yy_3D                   = repmat(y2d,[1 1 numSlices]);
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

numFiles_nuc            = size(dir_nuclei,1);
cells_to_discard        = [1 6 15 27 28 29 30];  % these cells are close to the edges, discard for now

% Colours
jet2    = jet;
jet3    = jet2(round(linspace(1,256,numFiles_nuc)),:);
[a,b]   = sort(rand(numFiles_nuc,1));
[c,d]   = sort(rand(numFiles_nuc,1));

%%
figure
for k=1:numFiles_nuc 
    %figure
    % Usual issue when reading the folders 10, 11, ... 19, 2, 20 ...
    % calculate the correct order (next time, save 1 as 01, 2 as 02, etc
    q           = strfind(dir_nuclei(k).name,'_');
    currCell    = str2num(dir_nuclei(k).name(q(2)+1:q(3)-1));
    %disp(currCell)
    if ~any(intersect(currCell,cells_to_discard))
        disp(currCell)
        load(dir_nuclei(k).name);
        % find the corresponding cell to the nuclei
        %for k2=1:numFiles_cell
        %    if ~isempty(strfind([dir_cell(k2).name],strcat('_',num2str(currCell),'_')))
        %        disp(k2)
                load(dir_cell(k).name);
        %    end
        %end
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
        surf_Cell          = isosurface(yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)  +final_coords(k,1) ,...
                                          xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) +final_coords(k,3) ,...
                                          zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) +final_coords(k,5) ,...
                                     Hela_cell(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.7);
                    
        % Finally, let's display the surface, allocate random colours
        h4                  = patch(surf_Nuclei);
        h4.FaceColor        = jet3(b(k),:);
        h4.EdgeColor        = 'none';
        h4.FaceAlpha        = 1;
        h5                  = patch(surf_Cell);
        h5.FaceColor        = jet3(d(k),:);
        h5.EdgeColor        = 'none';
        h5.FaceAlpha        = 0.2;
        
        %h4.FaceColor        = 'red';
        %h4.FaceColor        = 0.75*rand(1,3);
        
        % keep all the handles
        handlesNuclei{currCell}=h4;
        handlesCell  {currCell}=h5;
        
    end

    %title(dir_nuclei(k).name,'interpreter','none')
end
%%
    rotate3d on
view(74,47)
 lighting('phong');
hLight1 = camlight ('left');
%hLight2 = camlight ('right');
%axis tight
grid on

%% Insert a slice!
% Read first slice
SliceToRead             = 100;
currSlice               = imfilter(imread(strcat(baseDir,filesep,dirTiffs(SliceToRead).name)),ones(3)/9);
[rowsWhole,colsWhole]   = size(currSlice);
axis([1 rowsWhole 1 colsWhole 1 numTiffs])
[x2dWhole,y2dWhole]     = meshgrid(1:rowsWhole,1:colsWhole);
z2dWhole                     = ones(rowsWhole,colsWhole);
%%
hold on
fstep                   = 8;
currSliceSurf           = surf(x2dWhole(1:fstep:end,1:fstep:end),...
                               y2dWhole(1:fstep:end,1:fstep:end),...
                               SliceToRead*z2dWhole(1:fstep:end,1:fstep:end),...
                               currSlice(1:fstep:end,1:fstep:end)','edgecolor','none');
                           
colormap gray
%%
h1=gca;
set(gcf,'position',[ 500  200  900  500])
%%

h1.Position=[0.06 0.07 0.9 0.91];
%%
view(45,20)
filename ='Fig4a.png';
print('-dpng','-r300',filename)
view(75,70)
filename ='Fig4b.png';
print('-dpng','-r300',filename)

