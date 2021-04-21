clear all
close all

%% If folders already exist skip previous steps
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';


dirN                = dir(strcat(dir0,filesep,'Hela_ROI_*_Nuclei.mat'));
dirC                = dir(strcat(dir0,filesep,'Hela_ROI_*_Cell.mat'));
%%
numCells            = size(dirN,1);
load('final_coords.mat')
load(dirN(1).name);
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
numFiles            = numSlices;


%% Iterate over all folders and visualise all volumes in one figure
step            = 32;
step2           = 8;
fstep               = 16;
slicesToRead    = 1:step2:300;
numSlices       = size(slicesToRead,2);
figure
for currCell=1:numCells
    disp(currCell)
    load(dirN(currCell).name);
    load(dirC(currCell).name);    
    subplot(5,6,str2num(dirN(currCell).name(10:11)))
    
 
    
    surf_Nuclei          = isosurface(yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)   ,...
        xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)  ,...
        zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
        Hela_nuclei(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.7);
    surf_Cell          = isosurface(yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)   ,...
        xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) ,...
        zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
        Hela_cell(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.7);
    
    %        % Finally, let's display the surface, allocate random colours

    h1                  = patch(surf_Nuclei);
    h1.FaceColor        = 'r';
    h1.EdgeColor        = 'none';
    h1.FaceAlpha        = 0.99;
    h2                  = patch(surf_Cell);
    h2.FaceColor        = 'b';
    h2.EdgeColor        = 'none';
    h2.FaceAlpha        = 0.1;
    rotate3d on
    %title(,'interpreter','none')
    
    %
    view(-173,12)
    lighting('phong');
    hLight1 = camlight ('left');
    axis tight
    grid on
%     p1 = patch(isocaps(currSlices2(1:step:end,1:step:end,:), 5),'FaceColor','interp','EdgeColor','none');
%     currSlices2=currSlices;
%     currSlices2(1001:2000,:,:)=[];
%     p2 = patch(isocaps(currSlices2(1:step:end,1:step:end,:), 5),'FaceColor','interp','EdgeColor','none');
%     colormap gray
%     view(136,40)
%     axis tight
%     axis off
    title(strcat('(',(dirN(currCell).name(10:11)),')'),'fontsize',10)
    
    %
end
%%
for k=1:30
    subplot(5,6,k)
    handleAx(k)=gca;  
    axis ij
    view(45,45)
end
%%
vertPos = 0.8:-0.19:0;%[0.8 0.6 0.4 0.2 0.0];
horPos  = 0.02:0.165:0.89;
for k=1:30
    handleAx(k).Position(3:4)=[0.14 0.15];
    %  ceil([1:30]/6)  this locates the rows
    handleAx(k).Position(2) =vertPos (ceil(k/6));
    %  1+rem(-1+[1:30],6)  this locates the columns
    handleAx(k).Position(1) =horPos (1+rem(-1+k,6));
    if isempty(handleAx(k).Title.String)
        handleAx(k).Visible='off';
    end
     handleAx(k).View=[47 21];
     handleAx(k).XTickLabel='';
     handleAx(k).ZTickLabel='';
     handleAx(k).YTickLabel='';
end
%%
  set(gcf,'position',[ 400  200  900  530])


%%
filename ='Fig_allCells.png';
print('-dpng','-r300',filename)