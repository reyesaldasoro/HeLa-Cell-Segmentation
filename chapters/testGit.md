Contents {#contents .unnumbered .unnumbered}
--------

-   Read ROIs from The Crick

-   display 1 slice of 1 data set

Read ROIs from The Crick {#read-rois-from-the-crick .unnumbered .unnumbered}
------------------------

    dir0                = dir('*.tiff');

display 1 slice of 1 data set {#display-1-slice-of-1-data-set .unnumbered .unnumbered}
-----------------------------

    currentSet          = 12;
    currentName         = dir0(currentSet).name;
    currentSetInfo      = imfinfo(dir0(currentSet).name);
    numSlices           = size(currentSetInfo,1);

    filtG               = gaussF(5,5,1);

    %currentSlice=242;
    centralSlice        = round(numSlices/2);
    currentImage        = imread(dir0(currentSet).name,centralSlice);
    figure(1)
    imagesc(imfilter(currentImage,filtG))
    title(strcat(dir0(currentSet).name,'  (',num2str(currentSet),')    ','   -  ',num2str(centralSlice),'/',num2str(numSlices)),'interpreter','none')
    colormap gray
    Hela_nuclei(:,:,centralSlice) = segmentNucleiHelaEM(currentImage);
    Hela_background(:,:,centralSlice) = segmentBackgroundHelaEM(currentImage);

    figure(2)
    imagesc( Hela_nuclei(:,:,centralSlice));

    colormap gray

![image](testGit_01.eps){width="4in"}

![image](testGit_02.eps){width="4in"}
