function validateIndividualHelaROIs(Hela,IndividualHelaLabels)
% function validateIndividualHelaROIs(Hela,IndividualHelaLabels)
%--------------------------------------------------------------------------
% Input         Hela                : an image from which labels have been extracted
%               IndividualHelaLabels: This is a 3D matrix with the labels identifying 
%                                     the cells, but only one 2D slice should be
%                                     provided to select the cell itself (e.g.
%                                     (:,:,3)). This is
%                                     provided by detectNumberOfCells
% Output        no output, one image is displayed
%--------------------------------------------------------------------------
%
% This function displays one 8,000 x 8,000 images with numerous
% HeLa cells and overlaps the regions of interest and a number corresponding to the
% level at which the label has been stored.
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
[rows,cols,levs]                = size(IndividualHelaLabels);
numberROIS                      = levs;
%%
helaBoundary                    = zeros(rows,cols);
centralLabels                   = imerode(IndividualHelaLabels,ones(50));
boundariesLabels                = min(1-(IndividualHelaLabels-centralLabels),[],3);
hela2                           = double(imfilter(Hela,fspecial('gaussian',5,3)));

%%
figure
imagesc(boundariesLabels.*hela2)
colormap gray
for counterROI = 1:numberROIS
    positionsLabel                  = regionprops(IndividualHelaLabels(:,:,counterROI),'Centroid');
    text(positionsLabel.Centroid(1),positionsLabel.Centroid(2),num2str(counterROI),'fontsize',20,'color','r')
end

