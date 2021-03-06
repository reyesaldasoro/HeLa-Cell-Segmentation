function [Hela_nuclei,Hela_background] = segmentNucleiHelaEM_3D(baseDir,centralSlice,cannyStdValue)
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

%% Process over the whole cell
% Define the volumes
[rows,cols,numSlices]                   = size(Hela_3D);
Hela_nuclei(rows,cols,numSlices)        = 0;
Hela_background(rows,cols,numSlices)    = 0;
% Start with the central slice, this assumes the cell is centrally located,
% this may not be the case and may need to be reconsidered

if (~exist('centralSlice','var'))
    centralSlice                            = round(numSlices/2);
end
if (isempty(centralSlice))
    centralSlice                            = round(numSlices/2);
end

Hela_background(:,:,centralSlice)       = segmentBackgroundHelaEM(Hela_3D(:,:,centralSlice));
Hela_nuclei(:,:,centralSlice)           = segmentNucleiHelaEM(Hela_3D(:,:,centralSlice),[],cannyStdValue);    

%% iterate over all slices
for currentSlice=centralSlice+1:numSlices 
    % Iterate from the central slice UP, display the current position
    disp(strcat('Segmenting slice number',32,num2str(currentSlice)))
    Hela_background(:,:,currentSlice)   = segmentBackgroundHelaEM(Hela_3D(:,:,currentSlice));
    % only process the current slice if the previous contains results
    if (sum(sum(Hela_nuclei(:,:,currentSlice-1))))>0
        % Perform segmentation and save in the 3D Matrix       
        Hela_nuclei(:,:,currentSlice)       = segmentNucleiHelaEM(    Hela_3D(:,:,currentSlice),Hela_nuclei(:,:,currentSlice-1),cannyStdValue,Hela_background(:,:,currentSlice));
    else
        disp('no nuclei detected')
    end
end

% Go down using the central slice as a guide
%tic
for currentSlice=centralSlice:-1:1
    % Iterate from the central slice DOWN, display the current position
    disp(strcat('Segmenting slice number',32,num2str(currentSlice)))
    % Perform segmentation and save in the 3D Matrix
    Hela_background(:,:,currentSlice)   = segmentBackgroundHelaEM(Hela_3D(:,:,currentSlice));
    % only process the current slice if the previous contains results
    if (sum(sum(Hela_nuclei(:,:,currentSlice+1))))>0
        Hela_nuclei(:,:,currentSlice)       = segmentNucleiHelaEM(Hela_3D(:,:,currentSlice),Hela_nuclei(:,:,currentSlice+1),cannyStdValue,Hela_background(:,:,currentSlice));
    else
        disp('no nuclei detected')
    end
end
% This will no longer be needed, so delete to avoid out of memory problems
clear Hela_3D
%% overlap between background and nucleus, this should not happen.
if sum(sum(sum(Hela_background.*Hela_nuclei)))>0
    % dilate the background and remove from nuclei
    try
        Hela_nuclei                     = Hela_nuclei.*(1-imdilate(Hela_background,ones(39,39,23))) ;
    catch
        for counterS = 1:numSlices
            Hela_nuclei(:,:,counterS)   = Hela_nuclei(:,:,counterS).*(1-imdilate(Hela_background(:,:,counterS),ones(39,39,1))) ;
        end
    end
    
end

%% Interpolate between slices
% A simple post-processing step is to interpolate between slices/

% Hela_nuclei3(rows,cols,numSlices)   = 0;
% % interpolation between slices
% try
%     % This requires memory to have all slices in memory and may not run in all
%     % computers
%     Hela_nuclei3(:,:,2:numSlices-1) =   Hela_nuclei(:,:,1:numSlices-2)+...
%                                         Hela_nuclei(:,:,2:numSlices-1)+...
%                                         Hela_nuclei(:,:,3:numSlices);
% catch
%     for counterS = 2:numSlices-1
%         Hela_nuclei3(:,:,counterS) =   Hela_nuclei(:,:,counterS-1)+...
%                                         Hela_nuclei(:,:,counterS)+...
%                                         Hela_nuclei(:,:,counterS+1);
%     end
%     Hela_nuclei3(:,:,1)             =   Hela_nuclei(:,:,1);
%     Hela_nuclei3(:,:,numSlices)     =   Hela_nuclei(:,:,numSlices);
% end
% Hela_nuclei3                    = round(Hela_nuclei3);
% Hela_nuclei                     = Hela_nuclei3>1;
clear Hela_nuclei3;
% The 3D Median Filter may be better than the previous interpolation
Hela_nuclei                     = medfilt3(Hela_nuclei,[3 3 13]);
%%
% Hela_background3(rows,cols,numSlices)   = 0;
% % interpolation between slices
% try
%     % This requires memory to have all slices in memory and may not run in all
%     % computers
% 
%     Hela_background3(:,:,2:numSlices-1) =   Hela_background(:,:,1:numSlices-2)+...
%                                             Hela_background(:,:,2:numSlices-1)+...
%                                             Hela_background(:,:,3:numSlices);                               
% catch
%     for counterS = 2:numSlices-1
%         Hela_background3(:,:,counterS) =    Hela_background(:,:,counterS-1)+...
%                                             Hela_background(:,:,counterS)+...
%                                             Hela_background(:,:,counterS+1);
%     end
%     Hela_background3(:,:,1)             =   Hela_background(:,:,1);
%     Hela_background3(:,:,numSlices)     =   Hela_background(:,:,numSlices);
% end
%                                 
% Hela_background3                    = round(Hela_background3);
% Hela_background                     = Hela_background3>1;
% 
% clear Hela_background3
% Hela_nuclei is a logical and thus uses less memory than a double, reduce
% the background as well. Tested with logical and uint8 and uses the same
% space in disk but since nuclei is logical, keep consistent
Hela_background                     = medfilt3(Hela_background,[3 3 13]);
Hela_background = (Hela_background>0);
