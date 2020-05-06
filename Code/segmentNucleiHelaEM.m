function [nucleiHela,avNucleiIntensity,envelopeIntensity] = segmentNucleiHelaEM(Hela,previousSegmentation,cannyStdValue)
%function nucleiHela = segmentNucleiHelaEM(Hela,previousSegmentation,cannyStdValue)
%--------------------------------------------------------------------------
% Input         Hela                    : an image in Matlab format,it can be 2D/3D, double/uint8
%               previousSegmentation    : segmentation of slice above/below
%               cannyStdValue           : the value of the Std of the canny edge detection
% Output        nucleiHela              : a binary image with 1 for nuclei, 0 background
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



% Check dimensions of the data
[rows,cols,levs]            = size(Hela);

% Restrict to one channel and change to double if necessary
if levs>1
    Hela                    = double(Hela(:,:,1));
end
if ~isa(Hela,'double')
    Hela                    = double(Hela);
end
% Check the existance of Canny value,
if (~exist('cannyStdValue','var'))
    cannyStdValue            = 4;
end
if (isempty(cannyStdValue))
    cannyStdValue            = 4;
end

% Low pass filter for future operations
Hela_LPF                    = imfilter(Hela,fspecial('Gaussian',7,2));
%% Find edges and distance from those edges
Hela_Edge                   = edge(Hela,'canny',[],cannyStdValue);

%% processing of the edges could be done
% Hela_Edge_L               = bwlabel(Hela_Edge);
% Hela_Edge_LR              = regionprops(Hela_Edge,Hela_LPF,'area','eccentricity','meanintensity');
% Hela_Edge_L2              = bwlabel(ismember(Hela_Edge_L,find(( ([Hela_Edge_LR.Eccentricity]<145)&([Hela_Edge_LR.Area]>4) ) )));


%% Find location to keep the region at the centre and discard those that are close
% to the edges of the image

Hela_Edge_D                 = bwdist(Hela_Edge);

% THE DISTANCE DETERMINES WHEN EDGES WILL BE CONNECTED, WITH LARGER CANNY VALUES, THE
% EDGES MAY NOT CONNECT AT 5, SO BETTER TO INCREASE WITH THE CANNY VALUE
if cannyStdValue>6
    dilationEdges = 5+round(cannyStdValue/3);
else
    dilationEdges = 5;
end
Hela_Centroid       =  Hela_Edge+(Hela_Edge_D<dilationEdges);

Hela_Centroid2      = bwlabel(Hela_Centroid==0);
Hela_Centroid3      = regionprops(Hela_Centroid2,'Area','Centroid','eccentricity','extrema');

[Hela_Centroid4,numR]      = bwlabel(ismember(Hela_Centroid2,find([Hela_Centroid3.Area]>10000)));

if ~exist('previousSegmentation','var')
    
    Hela_Centroid5      = regionprops(Hela_Centroid4,'Area','Centroid','eccentricity','extrema');
    
    % Detect the extrema of regions
    Hela_ExtremaMin     = min(reshape(min([Hela_Centroid5.Extrema]),[2,numR]));
    Hela_ExtremaMax     = max(reshape(max([Hela_Centroid5.Extrema]),[2,numR]));
    % detect the extrema that will touch the first / last columns and rows, notice that
    % it is expected that rows and columns are equal, but this could have an impact with
    % rectangular images
    
    testExtreme1        = Hela_ExtremaMin<1;
    testExtreme2        = Hela_ExtremaMax>(min(rows,cols));
    
    % discard regions in the edges and at the same time fill holes in those that are kept
    % NOTE: WITH VERY LARGE REGIONS, THIS MAY BE THE REGION IN THE CENTRE WHICH EXPANDS
    % TO THE EDGES, THIS IS ESPECIALLY THE CASE WITH LARGE VALUES OF CANNY.
    
    Nuclei_0            = imfill(ismember(Hela_Centroid4,find(~(testExtreme1|testExtreme2))),'holes');
    
    % repeat labelling process to detect small and bringther regions and keep the region in the centre
    [Nuclei_1,numN]     = bwlabel(Nuclei_0);
    %Nuclei_2            = regionprops(Nuclei_1,Hela,'Area','MeanIntensity','Centroid');
    % % Centre the centroid with respect to rows and columns
    % centralRegionCoord=sqrt(sum((reshape([Nuclei_2.Centroid],[2 numN])'-repmat([cols/2 rows/2],numN,1)).^2,2));
    % % select the region which is closest to rows/2, cols/2
    % [minCentroid,posCentroid]= min(centralRegionCoord);
    % Nuclei_3  = (Nuclei_1==posCentroid);
    if numN ==0
        nucleiHela = zeros(rows,cols);
        return
    end       
    
    % Selection of centre-most region
    % The selection of the centremost region can be done with centroids, but if the
    % centre-most is slighlty shifted to the side and there is an annular shape that goes
    % around the central region, its centroid can be more in the centre and get
    % incorrectly selected. It is better to create a distance map from centroid, and use
    % that as an intensity map, then the region with lowest intensity would be selected
    % as centre-most
    
    Nuclei_DistFromCentre                               = zeros(rows,cols);
    Nuclei_DistFromCentre(round(rows/2),round(cols/2))  = 1;
    Nuclei_DistFromCentre                               = bwdist(Nuclei_DistFromCentre);
    
    Nuclei_2B = regionprops(Nuclei_1,Nuclei_DistFromCentre,'Area','MinIntensity','MeanIntensity','MaxIntensity','Centroid');

    % Centre the centroid with respect to rows and columns
    %centralRegionCoord=sqrt(sum((reshape([Nuclei_2.Centroid],[2 numN])'-repmat([cols/2 rows/2],numN,1)).^2,2));
    % select the region which is closest to rows/2, cols/2
    %[minCentroid,posCentroid]= min(centralRegionCoord);
    
    % select the region which is closest to rows/2, cols/2
    [minCentroid,posCentroid]   = min([Nuclei_2B.MinIntensity]);    
    Nuclei_3                    = (Nuclei_1==posCentroid);
else
    % If a previous segmentation exists, keep only those regions that are in contact
    % with the segmentation, as the segmentations are going up and down, it is
    % necessary to erode, however, if the erosion is too much, it will remove
    % everything
    
    Nuclei_0                    = Hela_Centroid4.*imerode(previousSegmentation,ones(20));
    Nuclei_0P                   = regionprops(Nuclei_0,'area');
    %regionsToKeep               = unique(Nuclei_0);
    regionsToKeep               = find([Nuclei_0P.Area]>100);
    Nuclei_1                    = ismember(Hela_Centroid4, regionsToKeep);
    Nuclei_1L                   = bwlabel(Nuclei_1);
    if max(Nuclei_1L(:))>1
        Nuclei_1P                   = regionprops(Nuclei_1L,'area');
        diffInAreas                 = abs(([Nuclei_0P(regionsToKeep).Area]-[Nuclei_1P.Area])./([Nuclei_1P.Area]));
        Nuclei_1F                   = ismember(Nuclei_1L,find(diffInAreas<0.25));
    else
        Nuclei_1F = Nuclei_1;
    end
    Nuclei_3                    = imfill((Nuclei_1F),'holes');
end

%% Obtain a distance transform to calculate the intensities of increasingly distant lines

Nuclei_4                        = round(bwdist(Nuclei_3));

%% find how the intensity changes from the edge of the nuclei so far
Nuclei_6(50)                    = 0;
for k=1:50
    Nuclei_6(k)                 =median(Hela_LPF(Nuclei_4==k));
end

% this should present a line that decreases up to a groove, corresponding to the
% nuclei envelope and then recover steadily
[envelopeIntensity,distMinIntensity]= min(Nuclei_6);
%% do a region growing to fit the boundary closer to darker pixels
% The growing will move the boundary outside towards darker pixels, When a boundary
% pixel is below a certain intensity level (determined by previous step) it is
% discarded. Once the number of valid pixels is below a threshold (150, it starts on
% several thousands) the process stops. Small boundary regions are discarded to
% prevent the region growing to flow outside the nuclei through a small gap. Also the
% number of dilations are restricted to 25 for the same reason

initRegion  = Nuclei_3;
k=0;
numPixBoundary = inf;

while (numPixBoundary>150)&(k<25)
    k=k+1;
    %disp(k)
    dilRegion   = imdilate(initRegion>0,ones(3))-initRegion;
    dilRegion2  = dilRegion .* (Hela_LPF>(envelopeIntensity+15));
    dilRegion3  = bwlabel(dilRegion2);
    dilRegion4  = regionprops(dilRegion3);
    dilRegion5 = ismember(dilRegion3,find([dilRegion4.Area]>7));
    numPixBoundary =  sum(sum(dilRegion5));
   % [k numPixBoundary]
    initRegion  = imfill(initRegion + dilRegion5,'holes');
end
%% Finally close to have a finer boundary
nucleiHela = imclose(initRegion,strel('disk',5));
nucleiHela = imfill(nucleiHela,'holes');

%% Final dilation
% Initial experiments showed that the result slightly underestimate the nuclei, so
% dilate by 5
%nucleiHela = imdilate(nucleiHela,ones(5));
nucleiHela              = imdilate(nucleiHela,strel('disk',5));
% calculate mean Intensity of Nuclei
avNucleiIntensity       =  mean(Hela(nucleiHela==1));



