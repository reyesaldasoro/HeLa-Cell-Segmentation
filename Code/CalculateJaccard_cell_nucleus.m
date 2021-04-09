%% Prepare segmentation of ROI HeLa Crick
baseDir                             = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329';
[Hela_nuclei,Hela_background]     	= segmentNucleiHelaEM_3D(baseDir);
[Hela_cell]                         = segmentCellHelaEM_3D(Hela_nuclei,Hela_background);


%%
%save('Results_ROI_1656_6756_329_2021_03_09B')

%% Load the ground truth
% GT == 1 Nuclear Envelope
% GT == 2 Nucleus
% GT == 3 other cells
% GT == 4 background
% GT == 5 cell
baseDir2     = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_5c';
dir2        = dir(strcat(baseDir2,filesep,'*.m*'));

numFiles    = size(dir2,1);

%currentGT(2000,2000,300)=0;
%% 
for k=1:numFiles
    disp(k)
    temp                = load((strcat(baseDir2,filesep,dir2(k).name)));
    current_GT(:,:,k)  = temp.groundTruth;
    %imagesc(currentGT(:,:,k))
end
%%
figure(1)
imagesc(squeeze(1*Hela_background(1000,:,:)+2*Hela_nuclei(1000,:,:)+3*Hela_cell(1000,:,:)))
figure(2)
imagesc(squeeze(current_GT(1000,:,:)))
              
%%

%%

figure(3)
currentSlice = 1200;

imagesc(squeeze((0*Hela_cell_noNucleus(currentSlice,:,:))+1*(current_GT(currentSlice,:,:)==5)))
%%
%Jaccard_Cell    = sum(sum(sum( (Hela_cell.*(1-Hela_nuclei)).*(current_GT==5) ))) / ...
%                  sum(sum(sum( (Hela_cell.*(1-Hela_nuclei))|(current_GT==5) )));
              
              
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
figure
k=119;
imagesc(TP(:,:,k)+2*TN(:,:,k)+3*FP(:,:,k)+4*FN(:,:,k))
 colormap gray

%% cell + Nucleus JI = 0.8711 Ac  =0.9655

current_GT2=current_GT;
current_GT2(current_GT2==5)=1;
current_GT2(current_GT2==2)=1;

TP              =  (Hela_cell+(current_GT2==1))==2;
TN              =  (Hela_cell+(current_GT2==1))==0;
FP              =  (Hela_cell-(current_GT2==1))==1;
FN              = (-Hela_cell+(current_GT2==1))==1;

Jaccard_Cell_Nuc  = sum(TP(:))/(sum(FP(:)+FN(:)+TP(:)));
Accuracy_Cell_Nuc = sum(TP(:)+TN(:))/sum(TN(:)+FP(:)+FN(:)+TP(:));
%%
figure
k=119;
imagesc(TP(:,:,k)+2*TN(:,:,k)+3*FP(:,:,k)+4*FN(:,:,k))
 colormap gray
%% Nucleus JI = 0.9665 Acc = 0.9975
TP              =  (Hela_nuclei+(current_GT==2))==2;
TN              =  (Hela_nuclei+(current_GT==2))==0;
FP              =  (Hela_nuclei-(current_GT==2))==1;
FN              = (-Hela_nuclei+(current_GT==2))==1;

Jaccard_Nucleus = sum(sum(sum( Hela_nuclei.*(current_GT==2) ))) / ...
                  sum(sum(sum( Hela_nuclei|(current_GT==2) )));
              
Accuracy_Nucleus = sum(sum(sum(Hela_nuclei==(current_GT==2))))/prod(size(Hela_nuclei));
%%
figure
k=119;
imagesc(TP(:,:,k)+2*TN(:,:,k)+3*FP(:,:,k)+4*FN(:,:,k))
 colormap gray
%%
currentSlice   = 115;
baseDir_data    = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329';

dir_data        = dir(strcat(baseDir_data,filesep,'*.t*'));
currentImage = imfilter(imread(strcat(baseDir_data,filesep,dir_data(currentSlice).name)),ones(5)/25);
%
composite(:,:,1) = currentImage+50*uint8(current_GT(:,:,currentSlice)==5);
composite(:,:,2) = currentImage+50*uint8(current_GT(:,:,currentSlice)==2);
composite(:,:,3) = currentImage;
figure(1)
imagesc(composite)
    set(gca,'position',[0 0 1 1 ]);axis off
    print('-dpng','-r400','Cell_Nucleus_groundTruth_115.png')

composite(:,:,1) = currentImage+50*uint8(Hela_cell(:,:,currentSlice)-Hela_nuclei(:,:,currentSlice));
composite(:,:,2) = currentImage+50*uint8(Hela_nuclei(:,:,currentSlice));
composite(:,:,3) = currentImage;
figure(2)
imagesc(composite)
    set(gca,'position',[0 0 1 1 ]);axis off
       print('-dpng','-r400','Cell_Nucleus_Segmentation_115.png')
       
% Detail
figure(1)
 axis([180 970 840 1800 ])
     print('-dpng','-r400','Cell_Nucleus_groundTruth_ROI_115.png')
 figure(2)
  axis([180 970 840 1800 ])
    print('-dpng','-r400','Cell_Nucleus_Segmentation_ROI_115.png')

