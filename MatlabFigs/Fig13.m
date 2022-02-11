%Fig 13
clear all
close all

%% Basic locations, Folder With TIFFS
baseDir             = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dirTiffs            = dir(strcat(baseDir,filesep,'*.tif*'));
numTiffs            = size(dirTiffs,1);   
%% Folder with the saved segmentations
%dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code';
dir0                = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Cell_Data\Matlab';

dir_nuclei          = dir(strcat(dir0,filesep,'Hela_RO*_Nu*.mat'));
dir_cell            = dir(strcat(dir0,filesep,'Hela_RO*_Ce*.mat'));
numFiles_nuc        = size(dir_nuclei,1);
numFiles_cell       = size(dir_cell,1);

%% Prepare for 3D display 
cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code')
load('final_coords.mat')
load(strcat(dir0,filesep,dir_nuclei(3).name))
%%
 figure
 fontsize=11;
for SliceToRead             = 330  %60:90:330
    currSlice               = imfilter(imread(strcat(baseDir,filesep,dirTiffs(SliceToRead).name)),ones(3)/9);
    [rowsWhole,colsWhole]   = size(currSlice);
    
    colormap gray
    composite(:,:,1)        = currSlice;
    composite(:,:,2)        = currSlice;
    composite(:,:,3)        = currSlice;
    
    for k=1:numFiles_nuc
        
        q           = strfind(dir_nuclei(k).name,'_');
        currCell    = str2num(dir_nuclei(k).name(q(2)+1:q(3)-1));
        %if the sliceToRead is present in the ROI process
        disp(strcat(num2str(SliceToRead),'-',num2str(currCell)))
        
        if (SliceToRead>=final_coords(currCell,5))&&(SliceToRead<=final_coords(currCell,6))
            load(strcat(dir0,filesep,dir_nuclei(k).name));
            load(strcat(dir0,filesep,dir_cell(k).name));
            rr              = final_coords(currCell,1):final_coords(currCell,2);
            cc              = final_coords(currCell,3):final_coords(currCell,4);
            nuclSlice       = Hela_nuclei(:,:,1+SliceToRead-final_coords(currCell,5));
            cellSlice       = Hela_cell  (:,:,1+SliceToRead-final_coords(currCell,5)).*(1-nuclSlice);
            composite(rr,cc,1) = composite(rr,cc,1)+50*uint8(cellSlice);
            composite(rr,cc,2) = composite(rr,cc,2)+50*uint8(nuclSlice);
        end
    end
    if SliceToRead ==60
         h1=subplot(2,2,1);
    elseif SliceToRead ==150
         h2=subplot(2,2,2);
    elseif SliceToRead ==240
         h3=subplot(2,2,3);
    elseif SliceToRead ==330
         h4=subplot(2,2,4);
         % add a scale bar, since the voxels are 10 nm, 500 pixels are 5 microns
         composite(7500:7650,6000:6500,:)=0;         
    end
      
        imagesc(composite)
        title(strcat('Slice = ',32,num2str(SliceToRead)),'fontsize',fontsize+4)
        for k=1:30
            if (SliceToRead>=final_coords(k,5))&&(SliceToRead<=final_coords(k,6))
           % if (SliceToRead>=final_centroid(k,4))&&(SliceToRead<=final_centroid(k,5))
                text(final_centroid(k,2),final_centroid(k,1),num2str(k),'fontsize',fontsize)
            else
                text(final_centroid(k,2),final_centroid(k,1),num2str(k),'fontsize',fontsize,'color','k')
            end
        end
        
    
end
%%

%h1=gca;
set(gcf,'position',[ 500  200  600  500])
%%
% For one subplot per figure
%h1.Position=[0.07 0.05 0.92 0.89];
hWidth=0.43;hHeight=0.41;
% For four subplots
h1.Position=[0.05 0.54 hWidth hHeight];
h2.Position=[0.54 0.54 hWidth hHeight];
h3.Position=[0.05 0.04 hWidth hHeight];
h4.Position=[0.54 0.04 hWidth hHeight];
h1.FontSize=8;h1.Title.FontSize=15;
h2.FontSize=8;h2.Title.FontSize=15;
h3.FontSize=8;h3.Title.FontSize=15;
h4.FontSize=8;h4.Title.FontSize=15;


%%
cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\MatlabFigs')

filename ='Fig13_scale.png';
print('-dpng','-r400',filename)

%% Zoom in and remove text as it can span to other subplots
for countChild=1:size(h4.Children,1)-1
    h1.Children(countChild).Visible = 'off';
    h2.Children(countChild).Visible = 'off';
    h3.Children(countChild).Visible = 'off';
    h4.Children(countChild).Visible = 'off';
end
 h1.Children(24).Visible = 'on';
 h2.Children(29).Visible = 'on';
 h3.Children(18).Visible = 'on';
 h3.Children(10).Visible = 'on';
 h4.Children(15).Visible = 'on';
 h4.Children(10).Visible = 'on';
  h4.Children(9).Visible = 'on';
h1.XLim =   1.0e+03 *[    4.1604    5.5854];
h1.YLim =   1.0e+03 *[    6.4398    7.7841];
h2.XLim =   1.0e+03 *[    4.3479    6.1111];
h2.YLim =   1.0e+03 *[    5.1994    6.8448];
h3.XLim =   1.0e+03 *[    2.8917    5.1137];
h3.YLim =   1.0e+03 *[    1.6744    4.1265];
h4.XLim =   1.0e+03 *[    4.3286    6.7493];
h4.YLim =   1.0e+03 *[    2.805    5.5419];


%%

filename ='Fig13_scale_zoom.png';
print('-dpng','-r400',filename)
