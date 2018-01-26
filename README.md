# HeLa-Cell-Segmentation
Segmentation of Nuclear Envelope of HeLa Cells observed with Electron Microscope

<h2>Segmentation of Nuclear Envelope of HeLa Cells observed with Electron Microscope</h2>

This code contains an image-processing pipeline for the automatic segmentation of the nuclear envelope of {\it HeLa} cells 
observed through Electron Microscopy. This pipeline has been tested with a 3D stack of 300 images. 
The intermediate results of neighbouring slices are further combined to improve the final results. 
Comparison with a hand-segmented  ground truth reported Jaccard similarity values between 94-98% on 
the central slices with a decrease towards the edges of the cell where the structure was considerably more complex.
The processing is unsupervised and  each 2D Slice is processed in about 5-10 seconds running on a MacBook Pro. 
No systematic attempt to make the code faster was made.

<h2> Brief description </h2>

The methodology consists of several image-processing steps: low-pass filtering, edge detection and determination of super-pixels, 
distance transforms and delineation of the nuclear envelope. 


<h2>Limitations</h2>


The algorithm assumes the following: there is a single HeLa cell of interest, the  centre of the cell is located at centre 
of a 3D stack of images, 
the nuclear envelope is darker than the nuclei or its surroundings, the background is brighter than any cellular structure.



<h2>Running the code</h2>

Assuming your image is a tiff file called 'Hela.tiff'

<pre class="codeinput">

Hela0 = imread('Hela.tiff');
Hela = double(Hela0(:,:,1));   
Hela_background   = segmentBackgroundHelaEM(Hela);
Hela_nuclei       = segmentNucleiHelaEM(Hela);    

</pre>

<h2>Results</h2>

The following animation shows a multi-slice segmentation where the segmented background is shaded in purple, 
the segmented nuclei is shaded in green, the ground truth is a red line.


![Screenshot](Hela_CombinedB_2017_09_07.gif)

