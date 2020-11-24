function [IndividualHelaLabels,rankCells,positionROI]        = detectNumberOfCells_3D(baseDir,numCells)
%function IndividualHelaLabels         = detectNumberOfCells_3D(baseDir,numCells)
% This function calls iteratively detectNumberOfCells in 2D to find all the
% cells in a stack, these will be in different positions and aligned.
%--------------------------------------------------------------------------
% Input         baseDir                 : a folder with a series of images
%               numCells             : optional, number of cells used to stop the
%                                      iterative process to detect cells
% Output        IndividualHelaLabels      : a 3D matrix with a label at each level
%                                      corresponding to the region of one cell.
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
        % It is a folder, take the central slice
              
        if (baseDir(end)~=filesep)
            baseDir = strcat(baseDir,filesep);
        end
        dir0        = dir (strcat(baseDir,'*.tif*'));
        

        numSlices                   = size(dir0,1);

    else
        % It is a file, read 

    end
    
else
    disp('This function processes multiple slices inside a folder');
    return
end

%%
stackInfo       = imfinfo((strcat(baseDir,dir0(1).name)));
rows            = stackInfo.Width;
cols            = stackInfo.Height;

%%
gaussFilt           = fspecial('Gaussian',3,1);
stepPix             = 4;
stepSlice           = 20;
probingSlices       = 1:stepSlice:numSlices;
numSlicesProb       = numel(probingSlices);
for k=1:numSlicesProb
    disp(strcat('Reading slice = ',32,num2str(k)))
    Hela_3D = ( imfilter(imread(strcat(baseDir,dir0(probingSlices(k)).name)), gaussFilt));
    [IndividualHelaLabels,rankCells(:,k),positionROI(:,:,k)]  = detectNumberOfCells(Hela_3D(1:stepPix:end,1:stepPix:end),20);
end
positionROI     = positionROI *stepPix;
%%

figure
clf
hold on

for k=1:numSlicesProb
    for kk=1:20
%        text(positionROI(kk,2,k),positionROI(kk,1,k),k,num2str(kk+(k-1)*20),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb])
        text(positionROI(kk,2,k),positionROI(kk,1,k),k,num2str(kk),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb])
    end
end

axis([1 8000 1 8000 1 numSlicesProb])
grid on
axis ij
rotate3d on
%% Find which cells are colocated
% find distance between cells in level 1 and cells in level 2 
% Since the image has been subsampled the distances are reduced, rescale

r1              = repmat(positionROI(:,1,1),[1,20]);
r2              = repmat(positionROI(:,1,2),[1,20])';
c1              = repmat(positionROI(:,2,1),[1,20]);
c2              = repmat(positionROI(:,2,2),[1,20])';
dist_1_2        = sqrt((r1-r2).^2+(c1-c2).^2);
[minDist_1_2,pairDist]     = min(round(dist_1_2),[],2);
% Find those cases where teh cells are less than   *** 150 *** pixels in
% straight line 


