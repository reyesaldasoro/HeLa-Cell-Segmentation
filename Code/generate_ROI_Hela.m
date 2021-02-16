function generate_ROI_Hela (baseDir,final_coords,final_centroid)
% function generate_ROI_Hela (baseDir,final_coords)
% A function to generate a series of regions of interest (i.e. cropped
% regions of 2,000 x 2,000 x 300) from a larger region of 8,000 x 8,000 x
% 512 pixels as obtained from an electron microscope scanning Hela Cells
%--------------------------------------------------------------------------
% Input         baseDir                 : a folder with a series of images
%               numCells                : optional, number of cells used to stop the
%                                         iterative process to detect cells
%               toPrint                 : optional to display where the
%                                         are located
% Output        final_centroid          : [numCell x 5 ]
%                                         [row,col,central,low/up slices]
%               final_cells             : [numCell x numSlicesProbed] with
%                                         one row for every cell located
%                                         and matched up down columns are
%                                         the slices probed (not all are to
%                                         speed up)
%               final_dist              : [numCell x numSlicesProbed] same
%                                         format as above with distance
%                                         from background
%
%--------------------------------------------------------------------------
%
% This code segments the REGION where HeLa Cells are located. The images have been
% acquired with Electron Microscopy at The Crick Institute by Chris Peddie, Anne
% Weston, Lucy Collinson and provided to the Data Study Group at the Alan Turing
% Insititute by Martin Jones.
%
% The code uses traditional image processing methods (edge detection, labelling,
% filtering, etc) to detect the regions where cells are located, ROUGHLY. It is
% intended as a step previous to a fine segmentation and removes the manual selection
% of cells by clicking in the centroid of the cell.
% It assumes the following:
%   1 Background is brighter than cells,
%   2 The background is detected automatically with segmentBackgroundHelaEM.m
%   3 As the image may have 20 or more cells, there are  2 ways to stop the iterative
%   process, one with the input argument to detect a determined number of cells, and
%   also the intensity of a distance map calculated in the algorithm, i.e. the
%   distance away from the background.
%
%  ------------------------ CITATION -------------------------------------
% This work has been accepted as an oral presentation in the conference:
%
% Medical Image Understanding and Analysis (MIUA) 2018 (https://miua2018.soton.ac.uk)
% please cite as:
% Cefa Karabag, Martin L. Jones, Christopher J. Peddie, Anne E.
% Weston, Lucy M. Collinson, and Constantino Carlos Reyes-Aldasoro, Automated
% Segmentation of HeLa Nuclear Envelope from Electron Microscopy Images, in
% Proceedings of Medical Image Understanding and Analysis, 7-9 July 2018,
% Southampton, UK. Usual disclaimer
%
% Usual disclaimer
%--------------------------------------------------------------------------
%
%     Copyright (C) 2018  Constantino Carlos Reyes-Aldasoro
%
%     This code is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, version 3 of the License.
%
%     The code is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     The GNU General Public License is available at <http://www.gnu.org/licenses/>.
%
%--------------------------------------------------------------------------



%% Check type of input
if isa(baseDir,'char')
    % check if it is a file or a folder
    if isfolder(baseDir)
        % It is a folder,
        if (baseDir(end)~=filesep)
            % check if the baseDir ends with / or \
            baseDir = strcat(baseDir,filesep);
        end
        % Read the directory IT HAS TO BE a tif or tiff to work
        dir0        = dir (strcat(baseDir,'*.tif*'));
        % calculate the number of slices,
        numSlices                   = size(dir0,1);
    else
        % It is a file, read NOT WORKING at the moment, only in folders
        disp('This function processes multiple slices inside a folder');
        return
    end
else
    disp('This function processes multiple slices inside a folder');
    return
end

%% Main parameters, number of cells, rows/cols per slice
% Number of cells
numCells            = size(final_coords,1);
% A gaussian to remove noise of slices to read
gaussFilt           = fspecial('Gaussian',3,1);
%% Processing option 1: read and save a single ROI
% for currCell        = 1:numCells
%     Hela_ROI            = zeros(2000,2000,300);
%     for k           = final_coords(currCell,5):final_coords(currCell,6)
%         % iterate over slices, read, filter and detect cells per slice
%         disp(strcat('Reading slice = ',32,num2str(k),' of cell =',32,num2str(currCell)))
%         Hela_3D     = ( (imread(strcat(baseDir,dir0((k)).name))));
%         Hela_ROI(:,:,k-final_coords(currCell,5)+1)    = imfilter(Hela_3D(final_coords(currCell,1):final_coords(currCell,2),final_coords(currCell,3):final_coords(currCell,4)), gaussFilt,'replicate');
%     end
%     % First cell has been cropped, save and return
%     Hela_ROI        = uint8(Hela_ROI);
%     filename        = strcat('Hela_ROI_',num2str(final_centroid(currCell,1)),'_',num2str(final_centroid(currCell,2)),'_',num2str(final_centroid(currCell,3)));
%     %save(filename,Hela_ROI)
% end
%% Processing option 2: read and save one image per ROI
% first, create the folders
for currCell            = 1:numCells
    foldername          = strcat('Hela_ROI_',num2str(currCell),'_',num2str(numCells),'_',num2str(final_centroid(currCell,1)),'_',num2str(final_centroid(currCell,2)),'_',num2str(final_centroid(currCell,3)));
    mkdir(foldername)
end
%% Now save all slices
for k           = 1:numSlices
    % iterate over slices, read, filter and detect cells per slice
    disp(strcat('Reading slice = ',32,num2str(k),' of cell =',32,num2str(currCell)))
    Hela_3D                 = imfilter(imread(strcat(baseDir,dir0((k)).name)), gaussFilt,'replicate');
    Hela_MASK               = zeros(rows,cols);
    for currCell            = 1:numCells
       % disp(currCell)
        rr                  = final_coords(currCell,1):final_coords(currCell,2);
        cc                  = final_coords(currCell,3):final_coords(currCell,4);
        Hela_ROI            = Hela_3D(rr,cc);
        %Hela_MASK(rr,cc,1)    = currCell;
        %imagesc(Hela_3D.*uint8(Hela_MASK==currCell))
        %drawnow
        %save current slice
        foldername          = strcat('Hela_ROI_',num2str(currCell),'_',num2str(numCells),'_',num2str(final_centroid(currCell,1)),'_',num2str(final_centroid(currCell,2)),'_',num2str(final_centroid(currCell,3)));
        filename            = strcat('ROI_',num2str(final_centroid(currCell,1)),'_',num2str(final_centroid(currCell,2)),'_',num2str(final_centroid(currCell,3)),'_z',num2str(k,'%3.4d'),'.tif');
        savefile            = strcat(foldername,filesep,filename);
        %save(filename,Hela_ROI)
        imwrite(Hela_ROI,savefile)
    end  
end



