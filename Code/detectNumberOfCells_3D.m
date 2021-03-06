function [final_coords,final_centroid,final_cells,final_dist,positionROI2]        = detectNumberOfCells_3D(baseDir,numCells,toDisplay)
%function IndividualHelaLabels         = detectNumberOfCells_3D(baseDir,numCells)
% This function calls iteratively detectNumberOfCells in 2D to find all the
% cells in a stack, these will be in different positions and aligned.
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
% Number of cells to detect per slice
if (~exist('numCells','var'))
    numCells            = 20;
end
if (isempty(numCells))
    numCells            = 20;
end

% To display
if (~exist('toDisplay','var'))
    toDisplay            = 0;
end
if (isempty(toDisplay))
    toDisplay            = 0;
end
% Find the dimensions of the first slice, as only tifs were read, there are
% no directories or else in the stack, otherwise you can use a mid slice
stackInfo       = imfinfo((strcat(baseDir,dir0(1).name)));
rows            = stackInfo.Width;
cols            = stackInfo.Height;
%% Processing settings,
% A gaussian to remove noise of slices to read
gaussFilt           = fspecial('Gaussian',3,1);
% slices are fairly similar so only a subset will be probed for cells,
% default is to read every 20 slices, which for 518 leaves 26 
stepSlice           = 20;
probingSlices       = 1:stepSlice:numSlices;
numSlicesProb       = numel(probingSlices);
% the slices will be subsampled (as they are 8,000 x 8,000
stepPix             = 4;
% these variables will store the rank of the cells detected per slice and
% location 
% RANKCELLS has 1 column per slice read and every row will have
% the rank (i.e. largest cell). 
rankCells           = zeros(numCells,numSlicesProb);
% POSITIONROI has one level per slice with r,c locations at ever
positionROI         = zeros(numCells,2,numSlicesProb);
for k=1:numSlicesProb
    % iterate over slices, read, filter and detect cells per slice
    disp(strcat('Reading slice = ',32,num2str(k)))
    Hela_3D = ( imfilter(imread(strcat(baseDir,dir0(probingSlices(k)).name)), gaussFilt));
    % extra parameter not read is a [rows,cols,numCells] matrix with the
    % location of each cell as a mask
    [~,rankCells(:,k),positionROI(:,:,k)]  = detectNumberOfCells(Hela_3D(1:stepPix:end,1:stepPix:end),numCells);
end
% Since the image has been subsampled the distances are reduced, rescale
positionROI     = positionROI *stepPix;
positionROI2    = positionROI;
%% Find which cells are colocated
% find distance between cells in level 1 and cells in level 2 
final_cells = [];
final_dist  = [];
%final_rank  = [];
%positionROI=qqq;
%% Link cells between slices
% there is a maximum distance to be accepted
maximum_distance    = 300;
% Iterate over slices
for startingSlice  = 1:numSlicesProb-1
    % Iterate over the cells present at current slice
    for cellAtSlice = 1:numCells
        %cellAtSlice                     = 2;
        if positionROI(cellAtSlice,1,startingSlice)<inf
            % only query if not yet processed, when processed, dist -> inf
            dist_i                          = zeros(1,numSlicesProb);
            cell_i                          = zeros(1,numSlicesProb);
            cell_i(startingSlice)           = cellAtSlice;
            %rank_i(startingSlice)           = rankCells(cellAtSlice,startingSlice);
            %cell_i_2(1)                    = cellAtSlice;
            dist_i(startingSlice)           = 0 ;
            for cSlices = startingSlice: numSlicesProb-1
                % now iterate over all slices ABOVE current selected cell
                dist_to_up                  = sqrt((positionROI(cell_i(cSlices),1,cSlices)-positionROI(:,1,cSlices+1)).^2+(positionROI(cell_i(cSlices),2,cSlices)-positionROI(:,2,cSlices+1)).^2);
                [min_up,match_up ]          = min(dist_to_up);
                % this will contain the chain of cells that are linked
                cell_i(cSlices+1)           = match_up;
                %cell_i_2(cSlices+1)        = match_up+cSlices*20;
                dist_i(cSlices+1)           = min_up;
                %rank_i(cSlices+1)           = rankCells(match_up,cSlices);
            end
            
            % propagate where the distance is large to break the connection
            dist_i(cumsum(dist_i>maximum_distance)>0)   = inf;
            cell_i(cumsum(dist_i>maximum_distance)>0)   = inf;
            %rank_i(cumsum(dist_i>maximum_distance)>0)   = inf;
            cellsToRemove                   = cell_i(cell_i<inf);
            cellsToRemove(cellsToRemove==0) =[];
            levCellsToRemove                =  find(cellsToRemove)+(startingSlice-1);
            % Accummulate cells
            final_cells = [final_cells;cell_i];
            final_dist  = [final_dist ;dist_i];
            %final_rank  = [final_rank ;rank_i];
            %remove the cells that have been accummulated
            for counterRemove=1:numel(cellsToRemove)
                positionROI(cellsToRemove(counterRemove),:,levCellsToRemove(counterRemove)) = inf;
            end
        end
    end
end

%% discard cases where there are 3 or less connections
% Each row corresponds to a chain of cells, the columns correspond to the
% level (i.e. the slice where it belongs)
final_cells(final_cells==inf) = 0;
final_dist(final_dist==inf)   = 0;
%final_rank(final_rank==inf)   = 0;


%% Keep only cells that span over a certain number of slices, 
% At least 150 slices so that it is more than half a cell
min_connections                 = (ceil(150/stepSlice));
%final_rank(sum(final_cells>0,2)<min_connections,:)   = [];
final_dist(sum(final_cells>0,2)<min_connections,:)  = [];
final_cells(sum(final_cells>0,2)<min_connections,:) = [];


%%
%final_cells(final_cells==0)=0;
numFinalCells = size(final_cells,1);

%% centroid [row column central_slice initial_slice final_slice]
final_centroid=zeros(numFinalCells,5);
    %currLine =[];
    for k=1:numFinalCells
        levsToPlot = find(final_cells(k,:));
        cellsToPlot = final_cells(k,levsToPlot);
        clear currLine
        currLine =[];
        for k2 =1:numel(levsToPlot)
            currLine = [currLine;[positionROI2(cellsToPlot(k2),:,levsToPlot(k2)) levsToPlot(k2) ]];
        end
        %plot3(currLine(:,2),currLine(:,1),currLine(:,3),'linewidth',2)
        final_centroid(k,:) = [round(mean(currLine)) levsToPlot(1) levsToPlot(end) ] ;
    end


final_centroid(:,3:5) = 1+ final_centroid(:,3:5)*(stepSlice)-stepSlice;
%%
if toDisplay ==1
    figure
    clf
    hold on
    
    for k=1:numSlicesProb
        for kk=1:numCells
            %        text(positionROI(kk,2,k),positionROI(kk,1,k),k,num2str(kk+(k-1)*numCells),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb])
            text(positionROI2(kk,2,k),positionROI2(kk,1,k),k,num2str(kk),'color',[k/numSlicesProb 0 (numSlicesProb-k)/numSlicesProb])
        end
    end
    
    axis([1 rows 1 cols 1 numSlicesProb])
    grid on
    axis ij
    rotate3d on
    %%
    
    %currLine =[];
    for k=1:numFinalCells
        levsToPlot = find(final_cells(k,:));
        cellsToPlot = final_cells(k,levsToPlot);
        clear currLine
        currLine =[];
        for k2 =1:numel(levsToPlot)
            currLine = [currLine;[positionROI2(cellsToPlot(k2),:,levsToPlot(k2)) levsToPlot(k2) ]];
        end
        plot3(currLine(:,2),currLine(:,1),currLine(:,3),'linewidth',2)
    end
end
%% Final step, determine the coordinates of ROIs so that they are 2,000 x 2,000 x 300
final_centroid2     = final_centroid;
% if centroids are closer than 1000 pixels from edge, shift (could discard)
final_centroid2(:,1) = max (final_centroid2(:,1),1001);
final_centroid2(:,1) = min (final_centroid2(:,1),rows-999);
final_centroid2(:,2) = max (final_centroid2(:,2),1001);
final_centroid2(:,2) = min (final_centroid2(:,2),cols-999);
% now adjust the z-level
final_centroid2(:,3) = max (final_centroid2(:,3),151);
final_centroid2(:,3) = min (final_centroid2(:,3),numSlices-149);

% determine the coordinates
final_coords (:,1) = max(1,      final_centroid2(:,1)      -1000);
final_coords (:,2) = min(rows,   final_centroid2(:,1)      +999);
final_coords (:,3) = max(1,      final_centroid2(:,2)      -1000);
final_coords (:,4) = min(rows,   final_centroid2(:,2)      +999);
final_coords (:,5) = max(1,      final_centroid2(:,3)      -150);
final_coords (:,6) = min(rows,   final_centroid2(:,3)      +149);




% r1              = repmat(positionROI(:,1,1),[1,numCells]);
% r2              = repmat(positionROI(:,1,2),[1,numCells])';
% c1              = repmat(positionROI(:,2,1),[1,numCells]);
% c2              = repmat(positionROI(:,2,2),[1,numCells])';
% dist_1_2        = sqrt((r1-r2).^2+(c1-c2).^2);
% [minDist_1_2,pairDist]     = min(round(dist_1_2),[],2);
% Find those cases where teh cells are less than   *** 150 *** pixels in
% straight line 


