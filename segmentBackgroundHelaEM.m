function [Hela_background,Background_intensity,Hela_intensity] = segmentBackgroundHelaEM(Hela)
%function  Hela_background = segmentBackgroundHelaEM(Hela)
%--------------------------------------------------------------------------
% Input         Hela       : an image in Matlab format,it can be 2D/3D, double/uint8
% Output        Hela_background      : a binary image with 1 for background 0 else
%               Background_intensity : average intensity of background (single value)
%               Hela_intensity       : average intensity of cell (single value)
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



% Check dimensions of the data
[rows,cols,levs]=size(Hela);

% Restrict to one channel and change to double if necessary
if levs>1
    Hela =double(Hela(:,:,1));
end
if ~isa(Hela,'double')
    Hela =double(Hela);
end

% Low pass filter for future operations
Hela_LPF = imfilter(Hela,fspecial('Gaussian',7,2));
%% Find edges and distance from those edges

%% Extend to detect background automatically

% Use a much blurrier edge detection to create large superpixels to detect the
% background

Hela_Edge       = imdilate(edge(Hela,'canny',[],9),ones(21));
Hela_supPix     = bwlabel(1-Hela_Edge);
Hela_supPixR    = regionprops(Hela_supPix,Hela_LPF,'Area','meanintensity');

%imagesc(Hela_supPix)
Hela_supPixBrightLarge = ismember(Hela_supPix,find(([Hela_supPixR.MeanIntensity]>160)&( [Hela_supPixR.Area]>1000 )   )  );
Hela_background = imfill(Hela_supPixBrightLarge,'holes');
Hela_background = imclose(Hela_background,strel('disk',39));
Hela_background = imfill(Hela_background,'holes');
%imagesc(Hela_background)
Background_intensity  =  mean(Hela(find(Hela_background)));
Hela_intensity  =  mean(Hela(find(1-Hela_background)));


