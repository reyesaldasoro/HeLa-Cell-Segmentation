% Fig6b.m
clear all
close all

cd ('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code')

baseDirTiff = ('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Hela_ROI_23_30_6816_1601_341\');
dir0        = dir(strcat(baseDirTiff,'*.tif'));


%% Ignore all previous data already calculated

load('Results_ROI_1656_6756_329_2021_03_09B.mat')
%% cell no Nucleus JI = 0.8094  Ac = 0.9629
Hela_cell_mask      = (current_GT==5)+(current_GT==1);
Hela_cell_noNucleus = (Hela_cell.*(1-Hela_nuclei));
TP              =  (Hela_cell_noNucleus+(Hela_cell_mask))==2;
TN              =  (Hela_cell_noNucleus+(Hela_cell_mask))==0;
FP              =  (Hela_cell_noNucleus-(Hela_cell_mask))==1;
FN              = (-Hela_cell_noNucleus+(Hela_cell_mask))==1;


Jaccard_Cell  = sum(TP(:))/sum(FP(:)+FN(:)+TP(:));
Accuracy_Cell = sum(TP(:)+TN(:))/sum(TN(:)+FP(:)+FN(:)+TP(:));
%%

%% cell + Nucleus JI = 0.8711 Ac  =0.9655

current_GT2=current_GT;
current_GT2(current_GT2==5)=1;
current_GT2(current_GT2==2)=1;

TP2              =  (Hela_cell+(current_GT2==1))==2;
TN2              =  (Hela_cell+(current_GT2==1))==0;
FP2              =  (Hela_cell-(current_GT2==1))==1;
FN2              = (-Hela_cell+(current_GT2==1))==1;

Jaccard_Cell_Nuc  = sum(TP2(:))/(sum(FP2(:)+FN2(:)+TP2(:)));
Accuracy_Cell_Nuc = sum(TP2(:)+TN2(:))/sum(TN2(:)+FP2(:)+FN2(:)+TP2(:));

%% Nucleus JI = 0.9665 Acc = 0.9975
TP3              =  (Hela_nuclei+(current_GT==2))==2;
TN3              =  (Hela_nuclei+(current_GT==2))==0;
FP3              =  (Hela_nuclei-(current_GT==2))==1;
FN3              = (-Hela_nuclei+(current_GT==2))==1;

Jaccard_Nucleus = sum(sum(sum( Hela_nuclei.*(current_GT==2) ))) / ...
                  sum(sum(sum( Hela_nuclei|(current_GT==2) )));
              
Accuracy_Nucleus = sum(sum(sum(Hela_nuclei==(current_GT==2))))/prod(size(Hela_nuclei));
%%
figure(6)
set(gcf,'position',[ 500  400  900  300])
%
%currSlide = 119;
k=currSlide;

%currImage = imfilter(imread(strcat(baseDirTiff,dir0(currSlide+-11).name)),ones(5)/25);

h311=subplot(131);
imagesc(1*TP(:,:,k)+2*TN(:,:,k)+3*FP(:,:,k)+4*FN(:,:,k))
title('(a)','fontsize',18)
    axis off
    
h312=subplot(132);
imagesc(1*TP2(:,:,k)+2*TN2(:,:,k)+3*FP2(:,:,k)+4*FN2(:,:,k))
title('(b)','fontsize',18)
    axis off
    
h313=subplot(133);
imagesc(1*TP3(:,:,k)+2*TN3(:,:,k)+3*FP3(:,:,k)+4*FN3(:,:,k))
title('(c)','fontsize',18)
colormap gray
    axis off
%
xWidth = 0.31;
yHeight = 0.87;
h311.Position    = [0.02    0.02    xWidth   yHeight];
h312.Position    = [0.35    0.02    xWidth   yHeight];
h313.Position    = [0.68    0.02    xWidth   yHeight];
%
% hTP = annotation(gcf,'textbox', [0.15 0.19 0.04 0.10],'String',{'TP'},'FitBoxToText','off');
% hTN = annotation(gcf,'textbox', [0.24 0.72 0.04 0.10],'String',{'TN'},'FitBoxToText','off');
% hFN = annotation(gcf,'textbox', [0.09 0.77 0.04 0.10],'String',{'FN'},'FitBoxToText','off');
% hFP = annotation(gcf,'textbox', [0.09 0.51 0.04 0.10],'String',{'FP'},'FitBoxToText','off');
hTP = annotation(gcf,'textbox', [0.15 0.19 0.05 0.11],'String',{'TP'},'FitBoxToText','off');
hTN = annotation(gcf,'textbox', [0.24 0.72 0.05 0.11],'String',{'TN'},'FitBoxToText','off');
hFN = annotation(gcf,'textbox', [0.07 0.77 0.05 0.11],'String',{'FN'},'FitBoxToText','off');
hFP = annotation(gcf,'textbox', [0.11 0.43 0.05 0.11],'String',{'FP'},'FitBoxToText','off');


hTP.FontName='Arial'; hTP.FontSize=18; hTP.EdgeColor='none';
hTN.FontName='Arial'; hTN.FontSize=18; hTN.EdgeColor='none';
hFP.FontName='Arial'; hFP.FontSize=18; hFP.EdgeColor='none';
hFN.FontName='Arial'; hFN.FontSize=18; hFN.EdgeColor='none';
%%
% hTP.Color=[1 1 1]*0/3;
% hTN.Color=[1 1 1]*1/3;
% hFP.Color=[1 1 1]*2/3;
% hFN.Color=[1 1 1];
% 
% hTN.BackgroundColor=[0 0.6 1];
% hTP.BackgroundColor=[0 0.6 1];
% hFP.BackgroundColor=[0 0.3 1];
% hFN.BackgroundColor=[0 0.1 1];

%%
hTP.Color=[1 1 1];
hTN.Color=[1 1 1];
hFP.Color=[1 1 1];
hFN.Color=[1 1 1];

hTN.BackgroundColor='none';
hTP.BackgroundColor='none';
hFP.BackgroundColor='none';
hFN.BackgroundColor='none';

%%
hArrow1 = annotation(gcf,'arrow',[0.114 0.145],[0.804 0.781]);
hArrow1.Color=[1 1 1]*0;
hArrow2 = annotation(gcf,'arrow',[0.132 0.118],[0.527 0.634]);
hArrow2.Color=[1 1 1]*0;
 %%
filename ='Fig6b.png';
print('-dpng','-r400',filename)