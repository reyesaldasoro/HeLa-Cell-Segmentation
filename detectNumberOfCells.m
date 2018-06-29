function IndividualHelaLabels         = detectNumberOfCells(hela,numCells)
%function IndividualHelaLabels         = detectNumberOfCells(hela,numCells)
%--------------------------------------------------------------------------
% Input         Hela                 : an image in Tiff or Matlab format preferably 2D,
%                                      double/uint8
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

%%
% This is one of the end parameters, number of cells to be detected by the algorithm
if ~exist('numCells','var')
    numCells = 25;
end
%% Detect Background of all the region

[helaBackground]                 = segmentBackgroundHelaEM(hela);

%% Initial processing
% Calculate size of the input image, it is usually 8192x8192
[rows,cols]                     = size(hela);
%
hela2                           = double(imfilter(hela,fspecial('gaussian',5,3)));
% set all the boundaries to one to remove bias on the edges
helaBackground(1,:)              = 1;
helaBackground(end,:)            = 1;
helaBackground(:,1)              = 1;
helaBackground(:,end)            = 1;
%% Initialise other variables
% Final segmentation, will contain a label per every region classified as cell
IndividualHelaLabels                           = zeros(rows,cols);
% Boundary of each region
helaBoundary                    = zeros(rows,cols);

%% Distance transform
% Calculate distance from background towards the cells, this should create some peaks
% for each of the cells
%
helaDistFromBackground          = bwdist(helaBackground);
%% find the maximum value of the distances (i.e. size of the largest cell) and discard
% those that are less than 50% that size, as they are not in that plane most likely
maxPeakAbs                         = max(max(helaDistFromBackground));
helaPeaks                       = imregionalmax(helaDistFromBackground.*(helaDistFromBackground>(0.5*maxPeakAbs)));

maxPeak                         = maxPeakAbs;
%% Iterate to find peaks/cells
currPeak                        = 1;
%%
while (currPeak<=numCells)&&(maxPeak>0)
    % Locate the largest peak, i.e. the largest cell, furthest away from background
    maxPeak                         = max(max(helaDistFromBackground.*helaPeaks));
    if maxPeak>(0.5*maxPeakAbs)
        [rr,cc]                         = find(helaDistFromBackground ==maxPeak);
        % Locate the spread of the cell as a square
        rr2                             = max(1,round(rr(1)-maxPeak*1.2)):min(rows,round(rr(1)+maxPeak*1.2));
        cc2                             = max(1,round(cc(1)-maxPeak*1.2)):min(cols,round(cc(1)+maxPeak*1.2));
        % Assing a label to the same region
        IndividualHelaLabels(rr2,cc2,currPeak)        = 1;
        % Remove the Distances/Peaks of the region to proceed to the next cell
        helaDistFromBackground(rr2,cc2) = 0;
        helaPeaks(rr2,cc2)              = 0;
        % Create boundaries for the region selected, mainly to display
        helaBoundary(rr2(1):rr2(1)+50    , cc2(1):cc2(end))         = 1;
        helaBoundary(rr2(end)-50:rr2(end), cc2(1):cc2(end))         = 1;
        helaBoundary(rr2(1):rr2(end)     , cc2(1):cc2(1)+50)        = 1;
        helaBoundary(rr2(1):rr2(end)     , cc2(end)-50:cc2(end))    = 1;
    end
    currPeak                        = currPeak+1;
end

