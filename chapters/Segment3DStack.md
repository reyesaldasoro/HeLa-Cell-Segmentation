---
DC.date: '2018-07-03'
DC.source: 'Segment3DStack.m'
generator: 'MATLAB 9.2'
title: Segment3DStack
---

::: {.content}
Contents
--------

<div>

-   [Process a whole stack of images](#1)
-   [Central Slice segmentation and display](#4)
-   [Multiple slices](#10)
-   [Interpolate between slices](#11)
-   [Display of the 3D segmentation](#12)

</div>

Process a whole stack of images {#1}
-------------------------------

This is a more detailed description of how to process a whole stack of
images that contain one HeLa cell, that is one Region of Interest (ROI)
consisting of approximately 300 slices each with dimensions 2,000 x
2,000 pixels. These can be saved as single slices inside a folder, or as
a multi-slice tiff. Let\'s assume that you have several multi-slice
tiffs. First, read all the files existing in that folder

``` {.codeinput}
dir0                    = dir('*.tiff');
```

It is practical to save this in a directory as later on you can select
the stack you want to process by choosing one of the files saved in the
directory, e.g.

``` {.codeinput}
currentSet              = 12;
currentName             = dir0(currentSet).name;
disp(currentName)
```

``` {.codeoutput}
ROI_3516-5712-314.tiff
```

Once this set has been selected, we can read the information of the file
to know how many slices are saved in this file:

``` {.codeinput}
currentSetInfo          = imfinfo(dir0(currentSet).name);
numSlices               = size(currentSetInfo,1);
```

Central Slice segmentation and display {#4}
--------------------------------------

Let\'s display the central slice of the stack:

``` {.codeinput}
centralSlice            = round(numSlices/2);
currentImage            = imread(dir0(currentSet).name,centralSlice);

filtG                   = fspecial('gaussian',5,3);

figure(1)
imagesc(imfilter(currentImage,filtG))
title(strcat(currentName,'  (',num2str(currentSet),')    ',...
    '   -  ',num2str(centralSlice),'/',num2str(numSlices)),'interpreter','none')
colormap gray
```

![](Segment3DStack_01.png)

Notice that we filtered the image with a Gaussian Low Pass filter for
display purposes as the original images are grainy. Notice also how we
displayed the name of the file, with the number of the set and the
current slice.

We can now segment the nucleus and the background of the current image.
We can do this with the following lines

``` {.codeinput}
Hela_nuclei(:,:,centralSlice)       = segmentNucleiHelaEM(currentImage);
Hela_background(:,:,centralSlice)   = segmentBackgroundHelaEM(currentImage);

figure(2)
imagesc(Hela_nuclei(:,:,centralSlice));
colormap gray
```

![](Segment3DStack_02.png)

Notice that we stored the result on a 3D matrix, with the level given by
the number of the central slice. This is done so that we can later on
save all the slices and create a 3D volume.

The segmentation on its own is not as revealing as when it is combined
with the original data. For that we can overlay on the original image,
using 3 levels for the RGB components:

``` {.codeinput}
CombinedResults (:,:,1) = currentImage;
CombinedResults (:,:,2) = currentImage+ 51*uint8(Hela_nuclei(:,:,centralSlice));
CombinedResults (:,:,3) = currentImage+ 75*uint8(Hela_background(:,:,centralSlice));
figure(3)
imagesc(CombinedResults);
```

![](Segment3DStack_03.png)

Notice first, the graininess of the original image, and also that, as
the original image was a uint8, we had to convert the results prior to
combining them.

Multiple slices {#10}
---------------

Once the central slice has been segmented, we can use that result as an
input argument to the function and do this iteratively for all the
slices of the set. We will go up first, and then down. For curiosity,
the time it takes to process all the slices will be calculated with
tic-toc

``` {.codeinput}
tic
for currentSlice=centralSlice+1:289
    % Iterate from the central slice UP, display the current position
    disp(currentSlice)
    % Read slice and convert to a double
    currentImage        = imread(dir0(currentSet).name,currentSlice);
    Hela                = double(currentImage(:,:,1));
    % Perform segmentation and save in the 3D Matrix
    Hela_background(:,:,currentSlice) = segmentBackgroundHelaEM(Hela);
    Hela_nuclei(:,:,currentSlice) = segmentNucleiHelaEM(Hela,Hela_nuclei(:,:,currentSlice-1));
end
t2=toc;

% Go down using the central slice as a guide
tic
for currentSlice=centralSlice:-1:47
    % Iterate from the central slice DOWN, display the current position
    disp(currentSlice)
    % Read slice and convert to a double
    currentImage        = imread(dir0(currentSet).name,currentSlice);
    Hela                = double(currentImage(:,:,1));
    % Perform segmentation and save in the 3D Matrix
    Hela_background(:,:,currentSlice)   = segmentBackgroundHelaEM(Hela);
    Hela_nuclei(:,:,currentSlice)       = segmentNucleiHelaEM(Hela,Hela_nuclei(:,:,currentSlice+1));
end
t3=toc;

disp(strcat('Total time: ',num2str(t2+t3)))
disp(strcat('Time per slice: ',num2str((t2+t3)/(289-47))))
```

``` {.codeoutput}
   151

   152

   153

   154

   155

   156

   157

   158

   159

   160

   161

   162

   163

   164

   165

   166

   167

   168

   169

   170

   171

   172

   173

   174

   175

   176

   177

   178

   179

   180

   181

   182

   183

   184

   185

   186

   187

   188

   189

   190

   191

   192

   193

   194

   195

   196

   197

   198

   199

   200

   201

   202

   203

   204

   205

   206

   207

   208

   209

   210

   211

   212

   213

   214

   215

   216

   217

   218

   219

   220

   221

   222

   223

   224

   225

   226

   227

   228

   229

   230

   231

   232

   233

   234

   235

   236

   237

   238

   239

   240

   241

   242

   243

   244

   245

   246

   247

   248

   249

   250

   251

   252

   253

   254

   255

   256

   257

   258

   259

   260

   261

   262

   263

   264

   265

   266

   267

   268

   269

   270

   271

   272

   273

   274

   275

   276

   277

   278

   279

   280

   281

   282

   283

   284

   285

   286

   287

   288

   289

   150

   149

   148

   147

   146

   145

   144

   143

   142

   141

   140

   139

   138

   137

   136

   135

   134

   133

   132

   131

   130

   129

   128

   127

   126

   125

   124

   123

   122

   121

   120

   119

   118

   117

   116

   115

   114

   113

   112

   111

   110

   109

   108

   107

   106

   105

   104

   103

   102

   101

   100

    99

    98

    97

    96

    95

    94

    93

    92

    91

    90

    89

    88

    87

    86

    85

    84

    83

    82

    81

    80

    79

    78

    77

    76

    75

    74

    73

    72

    71

    70

    69

    68

    67

    66

    65

    64

    63

    62

    61

    60

    59

    58

    57

    56

    55

    54

    53

    52

    51

    50

    49

    48

    47

Total time:1289.4234
Time per slice:5.3282
```

Interpolate between slices {#11}
--------------------------

A simple post-processing step is to interpolate between slices/

``` {.codeinput}
% Duplicate results
Hela_nuclei2            = Hela_nuclei;
Hela_nuclei2(1,1,290)   = 0;
% interpolation between slices
Hela_nuclei3(:,:,2:289) =   Hela_nuclei2(:,:,1:288)+...
                            Hela_nuclei2(:,:,2:289)+...
                            Hela_nuclei2(:,:,3:290);

Hela_nuclei3 = round(Hela_nuclei3);
```

Display of the 3D segmentation {#12}
------------------------------

Finally, we would like to visualise the results, there are several ways
to do this, one is to create a video or animated GIF changing the
slices, which will be described in a separate section. Here we will
display the 3D cell as a rendered surface. For this, we need to first
obtain the dimensions of the cell

``` {.codeinput}
[rows,cols,levs]        = size(Hela_nuclei);
```

We could create the surface directly with this, but as the volume is
rather large, the number of faces of the surface would be rather high,
it would be slow and may crash in a computer with low memory. This it is
better to generate the reference framework to create a isosurface with
fewer faces

``` {.codeinput}
[x2d,y2d]               = meshgrid(1:cols,1:rows);
z2d                     = ones(rows,cols);
x3d                     = repmat(x2d,[1 1 levs]);
y3d                     = repmat(y2d,[1 1 levs]);
z3d(rows,cols,levs)     = 0;
for counterSlice=1:levs
    z3d(:,:,counterSlice) = counterSlice*z2d;
end
```

We can now generate the isosurface of the cell, with a certain step;
using fstep =1 would be the same as the whole surface. With 8, the
results are still visually good and hard to distinguish with smaller
steps.

``` {.codeinput}
maxSlice            = 289;
minSlice            = 1;
fstep               = 8;
surf_Hela2          = isosurface(x3d(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                 y3d(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                                 z3d(1:fstep:end,1:fstep:end,minSlice:maxSlice),...
                        Hela_nuclei3(1:fstep:end,1:fstep:end,minSlice:maxSlice),1.5);
```

Finally, let\'s display the surface

``` {.codeinput}
figure(4)
h2 =  patch(surf_Hela2);
view(160,30)
lighting phong
camlight left
camlight right
set(h2,'facecolor','red')
set(h2,'edgecolor','none')
axis tight
```

![](Segment3DStack_04.png)

\
[Published with MATLAB®
R2017a](http://www.mathworks.com/products/matlab/)\
:::
