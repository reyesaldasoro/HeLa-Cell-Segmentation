function helaFinalLabels         = detectNumberOfCells(hela,numCells)

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
helaFinalLabels                           = zeros(rows,cols);
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
while (currPeak<numCells)&&(maxPeak>0)
    % Locate the largest peak, i.e. the largest cell, furthest away from background
    maxPeak                         = max(max(helaDistFromBackground.*helaPeaks));
    if maxPeak>(0.5*maxPeakAbs)
        [rr,cc]                         = find(helaDistFromBackground ==maxPeak);
        % Locate the spread of the cell as a square
        rr2                             = max(1,round(rr(1)-maxPeak*1.2)):min(rows,round(rr(1)+maxPeak*1.2));
        cc2                             = max(1,round(cc(1)-maxPeak*1.2)):min(cols,round(cc(1)+maxPeak*1.2));
        % Assing a label to the same region
        helaFinalLabels(rr2,cc2,currPeak)        = 1;
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

