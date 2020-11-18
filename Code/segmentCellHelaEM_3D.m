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
    % Find the distance transform from the background, then filter and use
    % watershed to determine where to "cut" the cell, especially when there
    % are 2 cells that are close to each other
    regionsCells    = watershed(- imfilter(bwdist(Hela_background),fspecial('Gaussian',3,1)  ));
    % find the region of the cell
    currentCell     = unique(cc(Hela_nuclei));
    % remove all other regions as well as the background and the nucleus
    Hela_cell       = (regionsCells==currentCell).*(1-Hela_background).*(1-Hela_nuclei);
    
else
    % Three dimensional case
    Hela_cell(rows,cols,numSlices)=0;
    for k=1:numSlices
        disp(strcat('Processing slice number',32,num2str(k)))
        Hela_cell(:,:,k) = segmentCellHelaEM_3D(Hela_nuclei(:,:,k),Hela_background(:,:,k));
    end
end
