function segmentHelaROI(inputFolder,IndividualHelaLabels,numberOfLabel,inputSlice)
% function segmentHelaROI(inputFolder,outputFolder,IndividualHelaLabels,numberOfLabel,inputSlice)
%--------------------------------------------------------------------------
% Input         inputFolder         : location of the input stack
%               outputFolder        : location where output stack will be saved
%               IndividualHelaLabels: This is a 3D matrix with the labels identifying 
%                                     the cells, but only one 2D slice should be used
%                                     to select the cell itself (e.g. (:,:,3)), thus
%                                     next argument is necessary. These are provided
%                                     by detectNumberOfCells
%               numberOfLabel       : the cell to be extracted
%               inputSlice          : the slice of the input stack from which the
%                                     data will be extracted
% Output        no output, all will be saved in the outputFolder
%--------------------------------------------------------------------------
%
% The code requires inputFolder,outputFolder,helaFinalLabels others are optional
%
% This function reads a folder where a stack of 8,000 x 8,000 images with numerous
% HeLa cells are stored, selects ONE region of interest and produces a reduced
% version of the data by cropping the images to a region of 2,000 x 2,000 and
% selecting that region in N (ideally 300) slices.
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


if nargin<3
    help segmentHelaROI;
    return
end
%%
% check that the folders exist, any problems with input will exit the programme
if ~exist(inputFolder,'dir')
    disp('---------------------------');
    disp('Input folder does not exist');
    disp('---------------------------');
    return
end
    
dirIn                      =  dir(strcat(inputFolder,'/*.tif*'));
numFilesIn                 =  size(dirIn,1);
if numFilesIn==0
    disp('---------------------');
    disp('Input folder is empty');
    disp('---------------------');
    return
end

%% The output Folder will be created with the name ROI_X_Y_Z coordinates

%% The region is crucial for detection and naming of the output folder
% The mask for the cell is required
if ~exist('IndividualHelaLabels','var')
    help segmentHelaROI;
    return
end

if ~exist('numberOfLabel','var')
    numberOfLabel              =  1;
end

[rows,cols,levs]               =  size(IndividualHelaLabels);
if levs>1
    CurrentHelaLabel            =  IndividualHelaLabels(:,:,numberOfLabel);
end
% Detect centroid of Labelled region
posLabel                       =  regionprops(CurrentHelaLabel,'Area','BoundingBox','Centroid');

%% select ROI


% Find the coordinates that will span 2000 x 2000 centred at the centroid, be careful
% with regions that are near the boundaries, for the time being, shift the box, but
% that would make the cell not be centred.

rInit                          =  ((posLabel.Centroid(2) - 1000));
cInit                          =  ((posLabel.Centroid(1) - 1000));

if (rInit<1)||(rInit>rows)
    % For the time being shift the ROI, could also pad with zeros or discard
    % altogether
    rInit                      =  min(max(1,posLabel.Centroid(2) - 1000),rows-2000);
end
if (cInit<1)||(cInit>cols)
    % For the time being shift the ROI, could also pad with zeros or discard
    % altogether
    cInit                      =  min(max(1,posLabel.Centroid(1) - 1000),cols-2000);
end

% Once the initial positions have been calculated, find the final positions
rFin                           =  rInit+1999;
cFin                           =  cInit+1999;

%%


%% Read all the files that need to be extracted, crop and save

% The input slice is useful, however if not provided, the central slice is selected
if ~exist('inputSlice','var')
    inputSlice                 =  max(1,floor(numFilesIn/2));
end

zInit                          =  max(1,inputSlice-300);
zFin                           =  min(numFilesIn,inputSlice+300);

%% Output folder name
outputLocation                  = strcat('ROI_',num2str(rInit),'-',num2str(cInit),'-',num2str(zInit));
outputFolder                    = strcat(outputLocation,'_',num2str(numberOfLabel));




% if output does not exist, it will be created.
if ~exist(outputFolder,'dir')
    disp('----------------------------');
    disp('Output folder does not exist');
    disp('Folder will be created');
    disp('----------------------------');
    mkdir(outputFolder)  
end

% to avoid problems overwriting files, only proceed if the folder is empty
dirOut                     =  dir(strcat(outputFolder,'/*.tif*'));
numFilesOut                =  size(dirOut,1);
if numFilesOut==0
%     disp('----------------------');
%     disp('Output folder is empty');
%     disp('----------------------');
else
    disp('------------------------------------------------');
    disp('Output folder is NOT empty');
    disp('Please use a different name or empty the folder');
    disp('------------------------------------------------');
    return    
end

%% Input and Output Folders exist. Check other parameters



%%
for counterFiles=zInit:zFin
    % Decide on how to name the files
    inFileName                 =  strcat(inputFolder,'/',dirIn(counterFiles).name);
    findExtension              = strfind(inFileName,'.');
    outFileName                =  strcat(outputLocation,'_z',inFileName(findExtension-4:end));
    
    %outFileName                =  strcat(outputFolder,'/ROI_',num2str(numberOfLabel),'_',dirIn(counterFiles).name);
    tempFile1                  =  imread(inFileName);
    tempFile                   =  tempFile1(rInit:rFin, cInit:cFin);
    imwrite(tempFile,strcat(outputFolder,'/',outFileName))
end











