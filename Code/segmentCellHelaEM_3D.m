function [Hela_cell] = segmentCellHelaEM_3D(Hela_nuclei,Hela_background)
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
if (nargin~= 2)
    disp('Two input parameters required')
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
    end
    % remove all other regions as well as the background and the nucleus
    currentCell         = ismember(regionsCells,currentCellRegs);
    %try
        Hela_cell1       = currentCell.*(1-Hela_background).*(1-Hela_nuclei);
        Hela_cell2       = imclose(Hela_cell1,ones(9));
        Hela_cell       = imfill(Hela_cell2,'holes');
        [Rest_cell,numR]= bwlabel((1-Hela_background).*(1-Hela_cell).*(1-Hela_nuclei));
    %catch
    %    q=1;
    %end

    Rest_cell_P     = regionprops(Rest_cell,'Area','Centroid','Extrema');
    Rest_cell_next  = unique(Rest_cell.*imdilate(Hela_cell,ones(3)));
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
    Hela_cell       = Hela_cell +RegionsToKeep3;
    
    % Finally, clean with morphological open and close
    Hela_cell       = imclose(imopen(Hela_cell,strel('disk',9)),strel('disk',9));

    
else
    % Three dimensional case
    Hela_cell(rows,cols,numSlices)=0;
    centralSlice                        = round(numSlices/2);
    % First go up
    for currentSlice=centralSlice+1:numSlices 
        disp(strcat('Processing slice number',32,num2str(currentSlice)))
        Hela_cell(:,:,currentSlice) = segmentCellHelaEM_3D(Hela_nuclei(:,:,currentSlice),Hela_background(:,:,currentSlice));
    end
    % Then go down
    for currentSlice=centralSlice:-1:1
        disp(strcat('Processing slice number',32,num2str(currentSlice)))
        Hela_cell(:,:,currentSlice) = segmentCellHelaEM_3D(Hela_nuclei(:,:,currentSlice),Hela_background(:,:,currentSlice));
    end
    
    
    %% Interpolate between slices
    % A simple post-processing step is to interpolate between slices/
    
    Hela_cell3(rows,cols,numSlices)   = 0;
    % interpolation between slices
%     Hela_cell3(:,:,2:numSlices-1) = Hela_cell(:,:,1:numSlices-2)+...
%                                     Hela_cell(:,:,2:numSlices-1)+...
%                                     Hela_cell(:,:,3:numSlices);
    Hela_cell3(:,:,3:numSlices-2) = Hela_cell(:,:,1:numSlices-4)+...
                                    Hela_cell(:,:,2:numSlices-3)+...
                                    Hela_cell(:,:,3:numSlices-2)+...
                                    Hela_cell(:,:,4:numSlices-1)+...
                                    Hela_cell(:,:,5:numSlices)    ;                                
    Hela_cell3                    = round(Hela_cell3);
    Hela_cell                     = Hela_cell3>2;

    %% Morphological operation per vertical slice
    Hela_cell=smooth3(Hela_cell);
    
    
    %%

end
