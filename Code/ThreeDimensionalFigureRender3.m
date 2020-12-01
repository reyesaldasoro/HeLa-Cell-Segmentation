%% Define the ROI (Alienware)
baseDir     = 'C:\Users\sbbk034\Documents\Acad\Crick\ROIs\ROI_1656-6756-329\';
dir0        = dir (strcat(baseDir,'*.tiff'));
numFiles    = size(dir0,1); 
%% Read all the slices of one ROI

Hela_3D(2000,2000,numFiles)=0;
gaussFilt =  fspecial('Gaussian',3,1);
for k=1:numFiles
    disp(k)
    Hela_3D(:,:,k) = imfilter(imread(strcat(baseDir,dir0(k).name)), gaussFilt);
end

%% Calculate or read
%[Hela_nuclei,Hela_background]   = segmentNucleiHelaEM_3D(Hela_3D);

load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_background.mat');
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_nuclei.mat');
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_cell.mat');



%% Interpolate between slices
% A simple post-processing step is to interpolate between slices/

% Duplicate results
Hela_nuclei2            = Hela_nuclei;
Hela_nuclei2(1,1,290)   = 0;
% interpolation between slices
Hela_nuclei3(:,:,2:289) =   Hela_nuclei2(:,:,1:288)+...
                            Hela_nuclei2(:,:,2:289)+...
                            Hela_nuclei2(:,:,3:290);

Hela_nuclei = round(Hela_nuclei3);


%% Prepare for 3D display 
% This is for the slices:

[rows,cols,levs]        = size(Hela_3D);
numFiles = levs;
[x2d,y2d]               = meshgrid(1:rows,1:cols);
z2d                     = ones(rows,cols);
zz_3D = zeros(size(Hela_3D));
for k=1:numFiles
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

maxSlice            = 289;
minSlice            = 1;
fstep               = 8;
surf_Hela2          = isosurface(xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                 yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                 zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                        Hela_nuclei(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.5);
                    
 %%                   
surf_Cell2          = isosurface(xx_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                 yy_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                 zz_3D(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                        Hela_cell(1:fstep:end,1:fstep:end,minSlice:maxSlice),0.5);
                    
%% Finally, let's display the surface
figure(4)
h2 =  patch(surf_Hela2);
%view(160,30)
view(398,43)
lighting phong
%camlight left
camlight right
set(h2,'facecolor','red')
set(h2,'edgecolor','none')
axis tight

%%
h3 =  patch(surf_Cell2);
set(h3,'facecolor','blue')
set(h3,'edgecolor','none')


%% Add Slices

horSlice = 68;
hold on
%horSliceSurf = surf(x2d(1:end/fstep,1:end/fstep),y2d(1:end/fstep,1:end/fstep),...
%                horSlice*zz1(1:end/fstep,1:end/fstep),(Hela_3D(1:fstep:end,1:fstep:end,horSlice)));
horSliceSurf = surf(xx_3D(:,:,horSlice),yy_3D(:,:,horSlice),zz_3D(:,:,horSlice),(Hela_3D(:,:,horSlice)));
horSliceSurf.EdgeColor='none';
%hold on
verSlice =500;
verSliceSurf = surf(squeeze(xx_3D(:,verSlice,:)),squeeze(yy_3D(:,verSlice,:)),squeeze(zz_3D(:,verSlice,:)),squeeze(Hela_3D(:,verSlice,:)));
verSliceSurf.EdgeColor='none';

colormap gray
%%
verSliceSurf.FaceAlpha=0.7;
h2.FaceAlpha=0.9152;
h3.FaceAlpha=0.5;

%%
% 
% for k=1:245
%     imagesc(Hela_nuclei(:,:,k))
%     drawnow
%     title(num2str(k))
%     pause(0.01)
% end
% 
% %%
% Hela_nuclei4 = Hela_nuclei;
% 
% Hela_nuclei4(1:5,1:5,119:120)=1;
% Hela_nuclei4(1995:2000,1995:2000,119:120)=1;
% 
% 
%     clf
%      fstep= 2;
%      h1 =patch(isosurface(Hela_nuclei4(1:fstep:end,1:fstep:end,1:244),0.5));
%      
%      set(h1,'facealpha',0.997)
% set(h1,'facecolor','red')
% set(h1,'edgecolor','none')
% view(35,5)
% 
% 
% 
% lighting phong
% camlight left
% camlight right
%  h1.FaceAlpha = 0.25;
% % %%
% % sizeFilter = 7;
% % 
% % slice60 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0060.tiff');
% % slice119 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0119.tiff');
% % slice160 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0160.tiff');
% % slice200 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0200.tiff');
% % slice60B = imfilter(slice60,gaussF(sizeFilter,sizeFilter,1));
% % slice119B = imfilter(slice119,gaussF(sizeFilter,sizeFilter,1));
% % slice160B = imfilter(slice160,gaussF(sizeFilter,sizeFilter,1));
% % slice200B = imfilter(slice200,gaussF(sizeFilter,sizeFilter,1));
% % 
% % 
% % %%
% % [rows,cols,levs]= size(slice200);
% % 
% % [xx1,y2d]=meshgrid(1:rows,1:cols);
% % zz1=ones(size(xx1));
% % hold on
% % %%
% % %pData = surf(xx1(1:fstep:end,1:fstep:end),y2d(1:fstep:end,1:fstep:end),119*zz1(1:fstep:end,1:fstep:end),(slice2(1:fstep:end,1:fstep:end,:)));
% % pData60 = surf(xx1(1:end/fstep,1:end/fstep),y2d(1:end/fstep,1:end/fstep),60*zz1(1:end/fstep,1:end/fstep),(slice60B(1:fstep:end,1:fstep:end,:)));
% % pData60.EdgeColor='none';
% % %%
% % %pData119 = surf(xx1(1:end/fstep,1:end/fstep),y2d(1:end/fstep,1:end/fstep),119*zz1(1:end/fstep,1:end/fstep),(slice119B(1:fstep:end,1:fstep:end,:)));
% % % pData119 = surf(xx1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),y2d(end/fstep/2:end/fstep,end/fstep/2:end/fstep),119*zz1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),(slice119B(end/2:fstep:end,end/2:fstep:end,:)));
% % % pData119.EdgeColor='none';
% % %%
% % %pData119 = surf(xx1(1:end/fstep,1:end/fstep),y2d(1:end/fstep,1:end/fstep),119*zz1(1:end/fstep,1:end/fstep),(slice119B(1:fstep:end,1:fstep:end,:)));
% % %pData160 = surf(xx1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),y2d(end/fstep/2:end/fstep,end/fstep/2:end/fstep),160*zz1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),(slice160B(end/2:fstep:end,end/2:fstep:end,:)));
% % %pData160 = surf(xx1(1:end/fstep,end/fstep/2:end/fstep),y2d(1:end/fstep,end/fstep/2:end/fstep),160*zz1(1:end/fstep,end/fstep/2:end/fstep),(slice160B(1:fstep:end,end/2:fstep:end,:)));
% % pData160 = surf(xx1(end/fstep/2:end/fstep,1:end/fstep),y2d(end/fstep/2:end/fstep,1:end/fstep),160*zz1(end/fstep/2:end/fstep,1:end/fstep),(slice160B(end/2:fstep:end,1:fstep:end,:)));
% % pData160.EdgeColor='none';
% % 
% % %%
% % %pData200 = surf(xx1(1:end/fstep,1:end/fstep),y2d(1:end/fstep,1:end/fstep),200*zz1(1:end/fstep,1:end/fstep),(slice200B(1:fstep:end,1:fstep:end,:)));
% % pData200 = surf(xx1(1:end/fstep/2,1:end/fstep/2),y2d(1:end/fstep/2,1:end/fstep/2),200*zz1(1:end/fstep/2,1:end/fstep/2),(slice200B(1:fstep:end/2,1:fstep:end/2,:)));
% % pData200.EdgeColor='none';
% % %%
% % h1.FaceAlpha = 0.4919;
% % 
% % %%
% % h1.FaceColor = 'c';
% % view(80,30)
% % colormap gray
% % %%
% % 
% % %axis([ 71 400 81 450 41 235])
% % axis([ 71 800 81 850 41 235])
% % 
% % %%
% % 
% % set(gca,'position',[0 -0.04 1 1.24])