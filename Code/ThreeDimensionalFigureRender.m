
load('nucleiHelaC_2018_02_01.mat')
load('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\nucleiHela_2018_02_01.mat')

%%

Hela_nuclei4 = Hela_nuclei3;

Hela_nuclei4(1:5,1:5,119:120)=1;
Hela_nuclei4(1995:2000,1995:2000,119:120)=1;


    clf
     fstep= 2;
     h1 =patch(isosurface(Hela_nuclei4(1:fstep:end,1:fstep:end,1:244),0.5));
     
     set(h1,'facealpha',0.997)
set(h1,'facecolor','red')
set(h1,'edgecolor','none')
view(35,5)



lighting phong
camlight left
camlight right
 h1.FaceAlpha = 0.25;
%%
sizeFilter = 7;

slice60 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0060.tiff');
slice119 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0119.tiff');
slice160 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0160.tiff');
slice200 = imread('/Users/ccr22/OneDrive - City, University of London/Acad/AllanTuringStudyGroup/Crick_Data/ROI_1656-6756-329/ROI_1656-6756-329_z0200.tiff');
slice60B = imfilter(slice60,gaussF(sizeFilter,sizeFilter,1));
slice119B = imfilter(slice119,gaussF(sizeFilter,sizeFilter,1));
slice160B = imfilter(slice160,gaussF(sizeFilter,sizeFilter,1));
slice200B = imfilter(slice200,gaussF(sizeFilter,sizeFilter,1));


%%
[rows,cols,levs]= size(slice200);

[xx1,yy1]=meshgrid(1:rows,1:cols);
zz1=ones(size(xx1));
hold on
%%
%pData = surf(xx1(1:fstep:end,1:fstep:end),yy1(1:fstep:end,1:fstep:end),119*zz1(1:fstep:end,1:fstep:end),(slice2(1:fstep:end,1:fstep:end,:)));
pData60 = surf(xx1(1:end/fstep,1:end/fstep),yy1(1:end/fstep,1:end/fstep),60*zz1(1:end/fstep,1:end/fstep),(slice60B(1:fstep:end,1:fstep:end,:)));
pData60.EdgeColor='none';
%%
%pData119 = surf(xx1(1:end/fstep,1:end/fstep),yy1(1:end/fstep,1:end/fstep),119*zz1(1:end/fstep,1:end/fstep),(slice119B(1:fstep:end,1:fstep:end,:)));
% pData119 = surf(xx1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),yy1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),119*zz1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),(slice119B(end/2:fstep:end,end/2:fstep:end,:)));
% pData119.EdgeColor='none';
%%
%pData119 = surf(xx1(1:end/fstep,1:end/fstep),yy1(1:end/fstep,1:end/fstep),119*zz1(1:end/fstep,1:end/fstep),(slice119B(1:fstep:end,1:fstep:end,:)));
%pData160 = surf(xx1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),yy1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),160*zz1(end/fstep/2:end/fstep,end/fstep/2:end/fstep),(slice160B(end/2:fstep:end,end/2:fstep:end,:)));
%pData160 = surf(xx1(1:end/fstep,end/fstep/2:end/fstep),yy1(1:end/fstep,end/fstep/2:end/fstep),160*zz1(1:end/fstep,end/fstep/2:end/fstep),(slice160B(1:fstep:end,end/2:fstep:end,:)));
pData160 = surf(xx1(end/fstep/2:end/fstep,1:end/fstep),yy1(end/fstep/2:end/fstep,1:end/fstep),160*zz1(end/fstep/2:end/fstep,1:end/fstep),(slice160B(end/2:fstep:end,1:fstep:end,:)));
pData160.EdgeColor='none';

%%
%pData200 = surf(xx1(1:end/fstep,1:end/fstep),yy1(1:end/fstep,1:end/fstep),200*zz1(1:end/fstep,1:end/fstep),(slice200B(1:fstep:end,1:fstep:end,:)));
pData200 = surf(xx1(1:end/fstep/2,1:end/fstep/2),yy1(1:end/fstep/2,1:end/fstep/2),200*zz1(1:end/fstep/2,1:end/fstep/2),(slice200B(1:fstep:end/2,1:fstep:end/2,:)));
pData200.EdgeColor='none';
%%
h1.FaceAlpha = 0.4919;

%%
h1.FaceColor = 'c';
view(80,30)
colormap gray
%%

%axis([ 71 400 81 450 41 235])
axis([ 71 800 81 850 41 235])

%%

set(gca,'position',[0 -0.04 1 1.24])