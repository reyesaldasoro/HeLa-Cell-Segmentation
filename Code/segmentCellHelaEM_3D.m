function [Hela_cell] = segmentCellHelaEM_3D(Hela_nuclei,Hela_background,Hela_cellPrevious)
%function [Hela_cell] = segmentCellHelaEM_3D(Hela_nuclei,Hela_background)
% This is the segments the CELL, i.e. the region between the background and
% the nuclei.
%--------------------------------------------------------------------------
% Input         Hela_nuclei             : 
%               Hela_background         : 
%                                      
% Output        Hela_Cell              : a binary volume with 1 for nuclei, 0 background
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
if (nargin<2)
    disp('Minimum two input parameters required')
    return
end

[rows,cols,numSlices]= size(Hela_nuclei);

if numSlices ==1
    % Two dimensional case
    % 
    areaNuclei      = sum(Hela_nuclei(:));
    % Find the distance transform from the background, then filter and use
    % watershed to determine where to "cut" the cell, especially when there
    % are 2 cells that are close to each other
    Hela_background_dist = imfilter(bwdist(Hela_background),fspecial('Gaussian',9,1));
    % level the peaks to avoid partitions
    maxHeight = max(Hela_background_dist(:));
    Hela_background_dist( Hela_background_dist>(maxHeight*0.70) )=(maxHeight*0.70);
    regionsCells    = watershed(-   Hela_background_dist);
    % find the region of the cell
    % if there is nuclei use this as guide, otherwise select the most
    % central one
    if areaNuclei>0
        currentCellRegs     = unique(regionsCells(Hela_nuclei));
        currentCellRegs(currentCellRegs==0)=[];
    else
        % No nuclei, requires some manipulations
        centroidsRegions = regionprops(regionsCells,'centroid','Area','MinoraxisLength');
        % Discard very narrow areas
        regionsCells = bwlabel(ismember(regionsCells,find([centroidsRegions.MinorAxisLength]>5)));
        centroidsRegions = regionprops(regionsCells,'centroid','Area','MinoraxisLength');
        posXY = [centroidsRegions.Centroid];
        posRC(:,1)  = posXY(1:2:end)-(rows/2);
        posRC(:,2)  = posXY(2:2:end)-(cols/2);
        distCentr   = sqrt(sum(posRC.^2,2));
        [minDist,centralReg]  = min(distCentr); 
        %currentCell         = ismember(regionsCells,centralReg);
        % Use a small range as there are cases where 
        currentCellRegs = find(distCentr<(minDist+30));
        %currentCellRegs = centralReg;
        % If we have the previous region, keep those regions covered by an
        % eroded version of the previous
        if exist('Hela_cellPrevious','var')
            % This erodes the previous cell, erodes a lot to avoid touching
            % many regions, then selects regions that are touched by the
            % previous, BUT when cell is very small, the background or
            % other cells may get be very close so discard big ones
            previousReg = regionsCells.*imerode(Hela_cellPrevious,ones(51));
            previousReg_P=regionprops(previousReg,'Area');
            currentCellRegs2 = unique(previousReg);
            currentCellRegs2(currentCellRegs2==0)=[];
            % Remove very large ones, anything larger than 70% previous
            % case
            previousSize = 0.5*sum(Hela_cellPrevious(:));
            currentCellRegs3 = intersect(find([previousReg_P.Area]<previousSize),currentCellRegs2);

            currentCellRegs = union(currentCellRegs,currentCellRegs3);
        end
    end
    % remove all other regions as well as the background and the nucleus
    currentCell         = ismember(regionsCells,currentCellRegs);
    %try
        Hela_cell1       = currentCell.*(1-Hela_background).*(1-Hela_nuclei);
        Hela_cell2       = imclose(Hela_cell1,ones(9));
        Hela_cell3       = imfill(Hela_cell2,'holes');
        [Rest_cell,numR]= bwlabel((1-Hela_background).*(1-Hela_cell3).*(1-Hela_nuclei));
    %catch
    %    q=1;
    %end

    Rest_cell_P     = regionprops(Rest_cell,'Area','Centroid','Extrema');
    Rest_cell_next  = unique(Rest_cell.*imdilate(Hela_cell3,ones(3)));
    Rest_cell_next(Rest_cell_next==0)=[];
    % Keep all the regions that are contiguous to the cell and have a small
    % area (10% nucleus)

    RegionsToKeep0  = (([(Rest_cell_P(Rest_cell_next).Area)]<(0.35*areaNuclei)));
    % discard regions that touch edges
    topLeft         = [Rest_cell_P.Extrema]<1;
    bottomRight1    = [Rest_cell_P.Extrema]>rows;
    bottomRight2    = [Rest_cell_P.Extrema]>cols;
    top             = topLeft(:,2:2:end)';
    left            = topLeft(:,1:2:end)';
    bottom          = bottomRight1(:,2:2:end)';
    right           = bottomRight2(:,1:2:end)';
    RegionsToKeep1  = find(1-any([top left bottom right],2));
    RegionsToKeep2   = Rest_cell_next(find(RegionsToKeep0));
    RegionsToKeep3  = ismember(Rest_cell,intersect(RegionsToKeep1,RegionsToKeep2));
    Hela_cell4       = Hela_cell3 +RegionsToKeep3;
    
    % Finally, clean with morphological open and close
    Hela_cell5       = imclose(imopen(Hela_cell4,strel('disk',9)),strel('disk',9));
    % Remove disconnected elements
    [Hela_cell_L,nReg]     = bwlabel(Hela_cell5);
    if nReg>1
        Hela_cell_P = regionprops(Hela_cell_L,'Area');
        [max1,max2]     = max([Hela_cell_P.Area]);
        Hela_cell       = ismember(Hela_cell_L,max2);
    else
        Hela_cell   = (Hela_cell_L==1);
    end
    %imagesc(Hela_cell+2*Hela_background)
    %drawnow
else
    % Three dimensional case
    Hela_cell(rows,cols,numSlices)=0;
    centralSlice                        = round(numSlices/2);
    
    % In some cases the background is not correctly detected, especially
    % when cells are very close to the edges. Even with a small specs of
    % background around the nuclei the cell is correctly limited, but when
    % there is no background on one side, the cell extends to the edge of
    % the ROI. To avoid this problem, a general view of the background can
    % be obtained by summing over all slices.
    Background_Projection               = sum(Hela_background,3);
    % Any region that is background in 66% of the slices must be
    % background, erode a bit from there
    General_background                  = imerode(Background_Projection>(0.66*numSlices), ones(9));
    %
    
    % First slice, central one 
    Hela_cell(:,:,centralSlice) = segmentCellHelaEM_3D(Hela_nuclei(:,:,centralSlice),Hela_background(:,:,centralSlice)|General_background);
   
    % First go up
    for currentSlice=centralSlice+1:155%numSlices 
        disp(strcat('Processing slice number',32,num2str(currentSlice)))
        Hela_cell(:,:,currentSlice) = segmentCellHelaEM_3D(Hela_nuclei(:,:,currentSlice),Hela_background(:,:,currentSlice)|General_background,Hela_cell(:,:,currentSlice-1));
        imagesc(Hela_background(:,:,currentSlice)+2*Hela_cell(:,:,currentSlice)+3*Hela_nuclei(:,:,currentSlice))
        qqq=1;
    end
    % Then go down
    for currentSlice=centralSlice-1:-1:130
        disp(strcat('Processing slice number',32,num2str(currentSlice)))
        Hela_cell(:,:,currentSlice) = segmentCellHelaEM_3D(Hela_nuclei(:,:,currentSlice),Hela_background(:,:,currentSlice)|General_background,Hela_cell(:,:,currentSlice+1));
         imagesc(Hela_background(:,:,currentSlice)+2*Hela_cell(:,:,currentSlice)+3*Hela_nuclei(:,:,currentSlice))
        qqq=1;
    end
    
    
%     %% Interpolate between slices
%     % A simple post-processing step is to interpolate between slices/
%     
%     Hela_cell3(rows,cols,numSlices)   = 0;
%     % interpolation between slices
% %     Hela_cell3(:,:,2:numSlices-1) = Hela_cell(:,:,1:numSlices-2)+...
% %                                     Hela_cell(:,:,2:numSlices-1)+...
% %                                     Hela_cell(:,:,3:numSlices);
%     Hela_cell3(:,:,3:numSlices-2) = Hela_cell(:,:,1:numSlices-4)+...
%                                     Hela_cell(:,:,2:numSlices-3)+...
%                                     Hela_cell(:,:,3:numSlices-2)+...
%                                     Hela_cell(:,:,4:numSlices-1)+...
%                                     Hela_cell(:,:,5:numSlices)    ;                                
%     Hela_cell3                    = round(Hela_cell3);
%     Hela_cell                     = Hela_cell3>2;
% 
%     %% Morphological operation per vertical slice
%     Hela_cell=smooth3(Hela_cell);
%     
%% a vertical median filter may be more effective than the previous interpolation and smoothing, and faster
Hela_cell           = medfilt3(Hela_cell,[3 3 13]);
%% overlap between background and cell, this should not happen.
if sum(sum(sum(Hela_background.*Hela_cell)))>0
    % dilate the background and remove from nuclei
    try
        Hela_cell                     = Hela_cell.*(1-imdilate(Hela_background,ones(9,9,3))) ;
    catch
        for counterS = 1:numSlices
            Hela_cell(:,:,counterS)   = Hela_cell(:,:,counterS).*(1-imdilate(Hela_background(:,:,counterS),ones(9,9,1))) ;
        end
    end
    
end

%% ensure there is only one region, remove small bits
[q]                 = bwlabeln(Hela_cell);
q2                  = regionprops(q,'Area');
if size(q2,1)>1
    [~,b]           = sort([q2.Area],'descend');
    Hela_cell       = q==(b(1));
end
end
