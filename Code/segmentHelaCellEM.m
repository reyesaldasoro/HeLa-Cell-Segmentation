function [cellRegion,dataOut] = segmentHelaCellEM(Hela_background,nucleiHela,Hela)
%function  Hela_background = segmentBackgroundHelaEM(Hela)
%--------------------------------------------------------------------------
% Input         Hela                 : an image in Matlab format,it can be 2D/3D, double/uint8
%               Hela_background      : a binary image with 1 for background 0 else
%               nucleiHela           : a binary image with 1 for nuclei 0 else
%              
% Output        cellRegion           : a binary image with 1 for the cell 0 else
%               dataOut              : an RGB with the cell region left in gray and the
%                                      nuclei and background highlighted in colours
%--------------------------------------------------------------------------
% 
%
% This code segments the whole cell of HeLa Cells that have been acquired with Electron
% Microscopy at The Crick Institute by Chris Peddie, Anne Weston, Lucy Collinson and
% provided to the Data Study Group at the Alan Turing Insititute by Martin Jones.
%
% The code uses traditional image processing methods (edge detection, labelling,
% filtering, etc) to detect the nuclei. It assumes the following:
%   1 the nuclei and background have been previously segmented.
% This code completes the segmentation of the cell and separates from other cells. 
% It works by partitioning the regions where background starts to appear.
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
%     Copyright (C) 2020  Constantino Carlos Reyes-Aldasoro
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
[rows,cols,levs]    = size(Hela);




distFromBack        = (bwdist(Hela_background));
distFromNucl        = (bwdist(nucleiHela));
breakDistFromBack   = (watershed(-imfilter(distFromBack,fspecial('Gaussian',[19],8))));
watershedsBack      = 1*imdilate((breakDistFromBack==0),ones(5));
regionsNotBackground= (bwlabel((1-watershedsBack).*(1-Hela_background)));
cellRegionClass     = unique(regionsNotBackground(nucleiHela>0));
cellRegionClass(cellRegionClass==0)=[];
cellRegion          = imclose(ismember(regionsNotBackground,cellRegionClass),ones(20));

if exist('Hela','var')
    filtG               = fspecial('Gaussian',3,0.85);
    HelaLPF             = imfilter(Hela,filtG,'replicate');
    dataOut             = imfilter(Hela,filtG,'replicate');
    dataOut(:,:,3)      = (cellRegion).*HelaLPF;
    dataOut(:,:,2)      = (1-nucleiHela).*HelaLPF;
    dataOut(:,:,2)      = dataOut(:,:,2)+0.75*(nucleiHela).*HelaLPF;
    
else
    dataOut = [];
end

