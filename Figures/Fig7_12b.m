% Fig3
clear all
close all
cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code')
%%
load('Hela_ROI_12_30_3501_1477_261_Cell.mat')
load('Hela_ROI_12_30_3501_1477_261_Nuclei.mat')



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


% Colours
jet2    = jet;
jet3    = jet2(round(linspace(1,256,numFiles)),:);
[a,b]   = sort(rand(numFiles,1));
[c,d]   = sort(rand(numFiles,1));

%%
fstep               = 8;

        surf_Nuclei          = isosurface(yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)   ,...
                                          xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)  ,...
                                          zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                    Hela_nuclei(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.7);
        surf_Cell          = isosurface(yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice)   ,...
                                          xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice) ,...
                                          zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                     Hela_cell(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.7);
                    
%        % Finally, let's display the surface, allocate random colours
figure
        h131=subplot(131);
        h1                  = patch(surf_Nuclei);
        h1.FaceColor        = 'y';
        h1.EdgeColor        = 'none';
        h1.FaceAlpha        = 0.7;
        h2                  = patch(surf_Cell);
        h2.FaceColor        = 'b';
        h2.EdgeColor        = 'none';
        h2.FaceAlpha        = 0.9;
            rotate3d on
    %title(,'interpreter','none')

%
view(-173,12)
 lighting('phong');
hLight1 = camlight ('left');
axis tight
grid on
title('(g)','fontsize',18)


       h132=subplot(132);
        h4                  = patch(surf_Nuclei);
        h4.FaceColor        = 'y';
        h4.EdgeColor        = 'none';
        h4.FaceAlpha        = 0.7;
        h5                  = patch(surf_Cell);
        h5.FaceColor        = 'b';
        h5.EdgeColor        = 'none';
        h5.FaceAlpha        = 0.2;
       title('(h)','fontsize',18) 
view(8,14)

 lighting('phong');
hLight2 = camlight ('left');
%hLight2 = camlight ('right');
axis tight
grid on



       h133=subplot(133);
        h6                  = patch(surf_Cell);
        h6.FaceColor        = 'b';
        h6.EdgeColor        = 'none';
        h6.FaceAlpha        = 1;
       title('(i)','fontsize',18) 
view(8,14)
 lighting('phong');
hLight3 = camlight ('left');
%hLight2 = camlight ('right');
axis tight
grid on



%
set(gcf,'position',[ 500  400  900  300])

%


hLight1.Position =[-12541    16485   -353];
hLight2.Position =[ 5065.0   -1615   -151]; 

hLight3.Position =[ 5065.0   -3115   -151]; 

%
h1.FaceAlpha        = 1;
h2.FaceAlpha        = 0.1;
h4.FaceAlpha        = 1;
h5.FaceAlpha        = 0.1;
%%
h131.Position=[0.04 0.1 0.28 0.8];
h132.Position=[0.37 0.1 0.28 0.8];
h133.Position=[0.7 0.1 0.28 0.8];
%%

filename ='Fig7_12b.png';
print('-dpng','-r300',filename)
