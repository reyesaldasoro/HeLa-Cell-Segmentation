function [Hela_background,Background_intensity,Hela_intensity,Hela_output] = segmentBackgroundHelaEM(Hela,avNucleiIntensity,nucleiHela)
%function  Hela_background = segmentBackgroundHelaEM(Hela)
%--------------------------------------------------------------------------
% Input         Hela       : an image in Matlab format,it can be 2D/3D, double/uint8
% Output        Hela_background      : a binary image with 1 for background 0 else
%               Background_intensity : average intensity of background (single value)
%               Hela_intensity       : average intensity of cell (single value)
%--------------------------------------------------------------------------
% 
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
%   was tested orginally for slices 70 to 135). However, further tests have
%   shown it works well for other data sets and even for the 8,000 x 8,000
%   images.
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

if ~exist('avNucleiIntensity','var')
    avNucleiIntensity       = 150;
end
if ~exist('nucleiHela','var')
    nucleiHela       = zeros(rows,cols);
end


% Low pass filter for future operations
Hela_LPF = imfilter(Hela,fspecial('Gaussian',7,2));
%% Find edges and distance from those edges

%% Extend to detect background automatically

% Use a much blurrier edge detection to create large superpixels to detect the
% background

Hela_Edge                   = imdilate(edge(Hela,'canny',[],9),ones(21));
Hela_supPix                 = bwlabel((1-Hela_Edge).*(1-nucleiHela));
Hela_supPixR                = regionprops(Hela_supPix,Hela_LPF,'Area','meanintensity');

% The background is assumed to be bright, if the average intensity of the nuclei is an input argument, use as
% a minimum level above which the background should be placed. Ideally calculate separately as well with Otsu


backgroundIntensity         = 5+min(max(avNucleiIntensity+10,255*graythresh(Hela_LPF/255)),200);
minSize                     = max(200,round(rows/10));


%imagesc(Hela_supPix)
Hela_supPixBrightLarge      = ismember(Hela_supPix,find(([Hela_supPixR.MeanIntensity]>backgroundIntensity)&( [Hela_supPixR.Area]>minSize )   )  );
% Create the background
Hela_background             = imfill(Hela_supPixBrightLarge,'holes');
Hela_background2             = imclose(Hela_background,strel('disk',39));
Hela_background3             = imopen(Hela_background2,strel('disk',19));

% Calculate average intensities
Background_intensity        =  mean(Hela(find(Hela_background)));
Hela_intensity              =  mean(Hela(find(1-Hela_background)));

% Grab the bright parts very close to the background (i.e. far from nuclei)
Hela_background4            = bwdist(Hela_background3); 
Hela_background5            = Hela>(Background_intensity-5);

% This allows to stretch close to the cells 
Hela_background6            = Hela_background5.*(Hela_background4<350).*(Hela_background4>0);

% This final filling of holes can remove whole cells
%Hela_background             = imfill(Hela_background,'holes');
Hela_background7             = imclose(Hela_background3+Hela_background6,ones(4));
%Hela_background8             = imopen(Hela_background7,strel('disk',6));

Hela_background9             = bwlabel(Hela_background7);
Hela_background9R            = regionprops(Hela_background9,'Area');
% Remove very small regions of background (inside cells most probably)
Hela_background10            = ismember(Hela_background9,find([Hela_background9R.Area]>(minSize*5 )   )  );

%Foreground                  = bwlabel(1-Hela_background10);
%ForegroundR                 = regionprops(Foreground,Hela_background4,'Area','minintensity');


 
% Final dilation to compensate for the original dilation of the edges
%Hela_background             = imdilate(Hela_background3+Hela_background6,strel('disk',2));
Hela_background             = imdilate(Hela_background10,strel('disk',2));
%Hela_background             = Hela_background7;

% Remove large holes in very large regions of background.

%imagesc(Hela_background)


Hela_output(rows,cols,3)    = 0;
Hela_output(:,:,1)          = Hela;
Hela_output(:,:,2)          = Hela.*(1-Hela_background)+0.7*Hela.*(Hela_background) ;
Hela_output(:,:,3)          = Hela.*(1-Hela_background)+0.7*Hela.*(Hela_background);
Hela_output=uint8(Hela_output);
%imagesc(Hela_output)
