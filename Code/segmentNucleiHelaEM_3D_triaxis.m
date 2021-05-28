function [Hela_nuclei_3ax,Hela_background_xy] = segmentNucleiHelaEM_3D_triaxis(baseDir,centralSlice)
%function nucleiHela = segmentNucleiHelaEM_3D(baseDir,previousSegmentation,cannyStdValue)
% This is the volumentric option of segmentNucleiHelaEM, it takes a stack
% of images and process them all
%--------------------------------------------------------------------------
% Input         baseDir                 : 1) A folder with n images in Matlab/tiff format,it can be 2D/3D, double/uint8
%                                       : 2) A tiff with many slices
%               centralSlice            : in case the cell is not centred
%                                         vertically, this is an optional parameter             
%               cannyStdValue           : the value of the Std of the canny edge detection
% Output        nucleiHela              : a binary volume with 1 for nuclei, 0 background
%--------------------------------------------------------------------------
%
% This code segments the nuclei of HeLa Cells that have been acquired with Electron
% Microscopy at The Crick Institute by Chris Peddie, Anne Weston, Lucy Collinson and
% provided to the Data Study Group at the Alan Turing Insititute by Martin Jones.
%
% The code uses traditional image processing methods (edge detection, labelling,
% filtering, etc) to detect the nuclei. It assumes the following:
%   1 A single cell is of interest and this cell has been cropped from a larger set
%   2 The cell is in the centre of the image
%   3 Although this is a 3D data set, the processing is done on 2D and then
%   post-processed (majority vote) once the whole data stack has been processed.
%   4 Some constants of intensity and size are required, thus this code may only
%   work for the middle region of the cell and not for the top and bottom edges (it
%   was tested for slices 70 to 135
%
%  ------------------------ CITATION -------------------------------------
% This work has been accepted as a journal paper:
%
% Medical Image Understanding and Analysis (MIUA) 2018 (https://miua2018.soton.ac.uk)
% please cite as:
%
% Cefa Karabag, Martin L. Jones, Christopher J. Peddie, Anne E.
% Weston, Lucy M. Collinson, and Constantino Carlos Reyes-Aldasoro,
% Segmentation and Modelling of the Nuclear Envelope of HeLa Cells Imaged
% with Serial Block Face Scanning Electron Microscopy,
% J. Imaging 2019, 5(9), 75; https://doi.org/10.3390/jimaging5090075
%
% Usual disclaimer
%--------------------------------------------------------------------------
%     
%     Copyright (C) 2017  Constantino Carlos Reyes-Aldasoro     
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
%% Parse input parameters
if isa(baseDir,'char')
    if isfolder(baseDir)
        % Hela is a folder where all the slides are located these must be
        % *.tiff or *.tif
        if (baseDir(end)~=filesep)
            baseDir = strcat(baseDir,filesep);
        end
        dir0        = dir (strcat(baseDir,'*.tif*'));
        numSlices   = size(dir0,1);
        if numSlices==1
            % Single image
            disp('This function processes multiple slices, for single images use segmentNucleiHelaEM_3D');
            return
        else
            % multiple images
            % Read info of first slice to format the 3D data
            infoSlices = imfinfo(strcat(baseDir,dir0(1).name));
            Hela_3D(infoSlices.Height,infoSlices.Width,numSlices)=0;
            gaussFilt =  fspecial('Gaussian',3,1);
            for k=1:numSlices
                disp(strcat('Reading slice number',32,num2str(k)))
                Hela_3D(:,:,k) = imfilter(imread(strcat(baseDir,dir0(k).name)), gaussFilt);
            end
        end
    else
        % baseDir is not a folder, it can be a file location
        % Read info of first slice to format the 3D data
        infoSlices = imfinfo(baseDir);          
        numSlices = size(infoSlices,1);
        % It is a string, check to see if it has many levels
        if numSlices==1
            % Single image
            disp('This function processes multiple slices, for single images use segmentNucleiHelaEM_3D');
            return
        else
            % multiple images
            Hela_3D(infoSlices.Height,infoSlices.Width,numSlices)=0;
            gaussFilt =  fspecial('Gaussian',3,1);
            for k=1:numSlices
                disp(strcat('Reading slice number',32,num2str(k)))
                Hela_3D(:,:,k) = imfilter(imread(baseDir,k), gaussFilt);
            end
        end
    end
else
    % last option, it can be a matlab matrix
    if (isa(baseDir,'double'))|(isa(baseDir,'uint8'))
        % Matrix, test size
        [rows,cols,numSlices]= size(baseDir);
        if numSlices==1
            % Single image
            disp('This function processes multiple slices, for single images use segmentNucleiHelaEM_3D');
            return
        else
            % multiple images
            Hela_3D = baseDir;
        end
    end
end
clear baseDir

%%
% Check the existance of Canny value,
if (~exist('cannyStdValue','var'))
    cannyStdValue            = 4;
end
if (isempty(cannyStdValue))
    cannyStdValue            = 4;
end

% Define the volumes
[rows,cols,numSlices]                   = size(Hela_3D);


% Permute for the tri-axis
Hela_3D_xz=permute(Hela_3D,[1 3 2]);
Hela_3D_yz=permute(Hela_3D,[3 2 1]);

[Hela_nuclei_xy,Hela_background_xy]     	= segmentNucleiHelaEM_3D(Hela_3D_xy,centralSlice,cannyStdValue);
[Hela_nuclei_xz,Hela_background_xz]     	= segmentNucleiHelaEM_3D(Hela_3D_xz,[],2);
[Hela_nuclei_yz,Hela_background_yz]     	= segmentNucleiHelaEM_3D(Hela_3D_yz,[],2);

% return the permute
Hela_nuclei_xz2=permute(Hela_nuclei_xz,[1 3 2]);
Hela_nuclei_yz2=permute(Hela_nuclei_yz,[3 2 1]);

%Hela_background_xz2=permute(Hela_background_xz,[1 3 2]);
%Hela_background_yz2=permute(Hela_background_yz,[3 2 1]);


% Add and filter
Hela_nuclei_3ax_sum = (Hela_nuclei_xy+Hela_nuclei_xz2+Hela_nuclei_yz2)>0;
Hela_nuclei_3ax_filt = medfilt3(Hela_nuclei_3ax_sum,[3 3 3]);

%Hela_background_3ax_sum = (Hela_background_xy+Hela_background_xz2+Hela_background_yz2)>0;
%Hela_background_3ax_filt = medfilt3(Hela_background_3ax_sum,[3 3 3]);

Hela_nuclei_3ax(rows,cols,levs)=0;
structEl            = strel('disk',11);
for k=1:numSlices
    Hela_nuclei_3ax(:,:,k) = imopen(Hela_nuclei_3ax_filt(:,:,k),structEl);
    %Hela_background_3ax(:,:,k) = imopen(Hela_background_3ax_filt(:,:,k),structEl);
end

