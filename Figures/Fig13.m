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
for SliceToRead             = 150:90:330
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
            load(dir_nuclei(k).name);
            load(dir_cell(k).name);
            rr              = final_coords(currCell,1):final_coords(currCell,2);
            cc              = final_coords(currCell,3):final_coords(currCell,4);
            nuclSlice       = Hela_nuclei(:,:,1+SliceToRead-final_coords(currCell,5));
            cellSlice       = Hela_cell  (:,:,1+SliceToRead-final_coords(currCell,5)).*(1-nuclSlice);
            composite(rr,cc,1) = composite(rr,cc,1)+50*uint8(cellSlice);
            composite(rr,cc,2) = composite(rr,cc,2)+50*uint8(nuclSlice);
        end
    end
          figure
        imagesc(composite)
        title(strcat('Slice = ',32,num2str(SliceToRead)))
        for k=1:30
            if (SliceToRead>=final_coords(k,5))&&(SliceToRead<=final_coords(k,6))
           % if (SliceToRead>=final_centroid(k,4))&&(SliceToRead<=final_centroid(k,5))
                text(final_centroid(k,2),final_centroid(k,1),num2str(k),'fontsize',18)
            else
                text(final_centroid(k,2),final_centroid(k,1),num2str(k),'fontsize',18,'color','k')
            end
        end
        
    
end
%%

h1=gca;
set(gcf,'position',[ 500  200  600  500])
%%

h1.Position=[0.07 0.05 0.92 0.9];
%%
filename ='Fig13A.png';
print('-dpng','-r300',filename)


