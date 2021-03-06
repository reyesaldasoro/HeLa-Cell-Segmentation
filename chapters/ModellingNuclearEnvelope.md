---
DC.date: '2018-08-03'
DC.source: 'ModellingNuclearEnvelopeHeLaCells.m'
generator: 'MATLAB 9.2'
title: ModellingNuclearEnvelope
---


Contents
--------

<div>

-   [Modelling the nuclear envelope of HeLa cells](#1)
-   [Reference](#2)
-   [Nuclear envelope shape modelling](#4)
-   [Ellipsoid or Sphere meshes](#10)
-   [Distance from Ellipsoids](#11)
-   [Modelling the Nuclear Envelope against the Ellipsoid](#12)

</div>


<a name="1"/>
</a>

Modelling the nuclear envelope of HeLa cells
-------------------------------

This script <b>ModellingNuclearEnvelopeHeLaCells.m </b>follows from the framework for the automatic segmentation of the
nuclear envelope of cancerous HeLa cells. In here, the surface of the nuclear envelope is modelled against  an  ellipsoid.  The modelling of the surface provides a visual
display of the variations, both smooth and rugged over the surface, and
measurements can be extracted with the expectation that they can
correlate with the biological characteristics of the cells.

<p>

---------------------- WARNING -----------------------------------------

Modelling the surface is done in 3D and it requires a large amount of
memory. This was tested on a MAC with 32 GB RAM and a PC with 8 GB RAM.
The PC required the conversion of doubles to singles to cope with the
large variables. On the MAC there were no problems. Computers with less
than 8 GB may not be able to run this script as it is and will require
some trick to reduce the sizes, i.e. subsampling of the data.

---------------------- WARNING -----------------------------------------

</p>

<a name="2"/>
</a>

Reference
-------------------------------

For a detailed description please consult:
Modelling the nuclear envelope of HeLa cells

Cefa Karabağ, Martin L Jones, Christopher J Peddie, Anne E Weston, Lucy M Collinson, Constantino Carlos Reyes-Aldasoro

doi: https://doi.org/10.1101/344986


Load previous results  
-------------------------------

It is assumed that the results of the segmentation of the nuclear
envelope is Detect centroid of the cell, first calculate the volume of
the cell and its limits up and down that will be called North and South
Poles as a geographic analogy.

``` {.codeinput}
load('nucleiHelaC_2018_02_01.mat')
[rows,cols,levs]= size(Hela_nuclei3);
clear Hela_background_3
```

The background is not needed so it is removed to free memory.
Detect centroid of the cell, first calculate the volume of
the cell and its limits up and down that will be called North and South
Poles as a geographic analogy.


``` {.codeinput}
massCell            = squeeze(sum(sum(Hela_nuclei3)));
totalVolume         = sum(massCell);
southPole           = find(massCell,1,'first');
northPole           = 15+find(massCell,1,'last');
```


Calculate the centroid of the cell based on the projections on all dimensions


``` {.codeoutput}
cell_xy             = sum(Hela_nuclei3,3);
cell_xz             = squeeze(sum(Hela_nuclei3,1))';
cell_yz             = squeeze(sum(Hela_nuclei3,2))';

cell_xyP             = regionprops(cell_xy>0,'Centroid');
cell_yzP             = regionprops(cell_yz>0,'Centroid');
cell_xzP             = regionprops(cell_xz>0,'Centroid');

centroid_Cell       = [ cell_xyP.Centroid(1) + cell_xzP.Centroid(1) ...
    cell_xyP.Centroid(2) + cell_yzP.Centroid(1) ...
    cell_xzP.Centroid(2) + cell_yzP.Centroid(2)]/2;
```

Equivalent sphere
-------------------------------

We can use (20/number of slices) as parallels to display the model against which
the cell will be compared, it can be a sphere or an ellipse. Use
northpole - southpole to generate a mesh to extract the surface of the
cell

``` {.codeoutput}

%numParallels = 20;
numParallels = northPole-southPole;
```

A general sphere of radius 1 centred at the origin

``` {.codeoutput}
[x_Sph0,y_Sph0,z_Sph0]  = sphere(numParallels);
```

The equivalent radius is a single value that will multiply all points
equally

``` {.codeoutput}
equivRadius             = (totalVolume*3/4/pi).^(1/3);

x_Sph                   = x_Sph0*equivRadius + centroid_Cell(1);
y_Sph                   = y_Sph0*equivRadius + centroid_Cell(2);
z_Sph                   = z_Sph0*equivRadius + centroid_Cell(3);
```

<a name="4"/>
</a>

Nuclear envelope shape modelling.
-------------------------------

To further study the shape of the segmented NE, this was modelled against
a 3D ellipsoid. The ellipsoid was adjusted to have the same volume as the
nucleus. The equivalent radius is a vector that will multiply each z
level equally but the levels are not spherical



``` {.codeinput}
height                  = ( northPole-southPole )/2;
equivRadiusC            = (totalVolume*3/4/pi/height).^(1/2);

heightVec               = linspace(-height,height,numParallels+1);
radiusVec               = ( equivRadiusC*equivRadiusC* (1 - (heightVec.^2)/(height^2))  ).^(1/2);
radiusMat               = repmat(radiusVec',[1 numParallels+1]);
zDisplacement           = linspace(southPole,northPole,numParallels+1);

% Equivalent Ellipsoid
x_Ellip                 = x_Sph0.*radiusMat + centroid_Cell(1);
y_Ellip                 = y_Sph0.*radiusMat + centroid_Cell(2);
z_Ellip                 = z_Sph0*height + centroid_Cell(3);
```



Generate the reference framework to create a isosurface with fewer faces
--------------------------------------


``` {.codeinput}

[x2d,y2d]               = (meshgrid(1:cols,1:rows));
z2d                     = int16(ones(rows,cols));
x2d = int16(x2d);
y2d = int16(y2d);
```

When the memory is limited, subsample for the 3D case

``` {.codeinput}
SubStep = 1;
x3d                     = repmat(x2d(1:SubStep:end,1:SubStep:end),[1 1 levs]);
y3d                     = repmat(y2d(1:SubStep:end,1:SubStep:end),[1 1 levs]);
%%
z3d(rows/SubStep,cols/SubStep,levs)     = int16(0);
for counterSlice=1:levs
    disp(counterSlice)
    z3d(:,:,counterSlice) = counterSlice*z2d(1:SubStep:end,1:SubStep:end);
end

z3d = int16(z3d);
```




Generate the isosurface of the cell
--------------------------------------

This generates an isosurface that has been subsampled for computational
efficiency. With a step of 16 there are visible artifacts


``` {.codeinput}
fstep= 8;
surf_Hela2          = isosurface(single(x3d(1:fstep:end,1:fstep:end,1:levs)),...
    single(y3d(1:fstep:end,1:fstep:end,1:levs)),...
    single(z3d(1:fstep:end,1:fstep:end,1:levs)),...
    Hela_nuclei3(1:fstep:end,1:fstep:end,1:levs),0.5);
```


Start the display with the cell surface
--------------------------------------


``` {.codeinput}

figure

handleSurfaceNuclearEnvelope =  patch(surf_Hela2);

lighting phong
camlight left
camlight right
set(handleSurfaceNuclearEnvelope,'facecolor','red')
set(handleSurfaceNuclearEnvelope,'edgecolor','none')

handleSurfaceNuclearEnvelope.FaceAlpha = 0.75;
```


<a name="10"/>
</a>

Ellipsoid or Sphere meshes
--------------------------------------


Spheres do not adjust well to some cells that tend to be flatter. If you want to compare against a sphere, uncomment the following lines:

``` {.codeinput}
% hold on
% h_Sph                   = mesh(x_Sph,y_Sph,z_Sph);
% h_Sph.FaceColor='none';
% h_Sph.LineWidth=2;
```


We can now generate an ellipse and compare against the cell:
``` {.codeinput}
hold on
handle_Ellipsoid                    = mesh(x_Ellip,y_Ellip,z_Ellip);

handle_Ellipsoid.EdgeColor          = 'none';
handle_Ellipsoid.FaceColor          = 'b';
handle_Ellipsoid.LineWidth          = 2;
handle_Ellipsoid.FaceAlpha          = 0.75;
axis tight; grid on
```

The figure below shows the case where only 20 parallels were used to generate the sphere:


![](Figures/Hela_Ellipse_Rotate.gif)

The figure below shows the case where the same number of slices and parallels was used:

![](Figures/Hela_Ellipse_Comparison.png)




<a name="11"/>
</a>

Distance from Ellipsoid
--------------------------------------


The  surfaces  of  the  ellipsoid  and  the  nucleus  were  subsequently
compared  by tracing rays from the centre of the ellipsoid and the
distance between the surfaces for each ray was calculated. It was assumed
that when the nucleus surface was  further  away  from  the  centre,  the
difference  was  positive.

``` {.codeinput}
heightVec2              = linspace(-height,height,round(2*height)+1);
radiusVec2               = ( equivRadiusC*equivRadiusC* (1 - (heightVec2.^2)/(height^2))  ).^(1/2);


eqEllip(rows,cols,levs) =single(0);
circRef             = ( (single(x2d -centroid_Cell(1))).^2 + (single(y2d - centroid_Cell(2))).^2).^(0.5);

for counterSlice=southPole:northPole
    % Iterate over all slices
    disp(counterSlice)
    eqEllip(:,:,counterSlice)   = single(circRef<radiusVec2(counterSlice-southPole+1));   
end
% Convert to a single to save memory
eqEllip=single(eqEllip);
```


Display of the ellipsoid against the cell per slice
``` {.codeinput}
clear F
figure
h0=gcf;
for counterSlice=southPole:min(levs,northPole)
    disp(counterSlice)
    imagesc(2*Hela_nuclei3(:,:,counterSlice)+eqEllip(:,:,counterSlice));    
    title(strcat('Slice: ',num2str(counterSlice),', Jaccard:',num2str(sum(sum(Hela_nuclei3(:,:,counterSlice).*eqEllip(:,:,counterSlice)))/sum(sum(Hela_nuclei3(:,:,counterSlice)|eqEllip(:,:,counterSlice))))))
    drawnow
    pause(0.01)
    F(counterSlice-southPole+1) = getframe(h0);
end
```
![](Figures/Hela_Ellipse_Jaccard.gif)

Save as a video

``` {.codeinput}v = VideoWriter('Hela_Ellipse_Jaccard.mp4', 'MPEG-4');
open(v);
writeVideo(v,F);
close(v);
```

Save as a GIF

``` {.codeinput}
[imGif,mapGif] = rgb2ind(F(11).cdata,256,'nodither');
numFrames = size(F,2);

imGif(1,1,1,numFrames) = 0;
for k = 2:numFrames
    imGif(:,:,1,k) = rgb2ind(F(k).cdata,mapGif,'nodither');
end
imwrite(imGif,mapGif,'Hela_Ellipse_Jaccard.gif',...
    'DelayTime',0,'LoopCount',inf)
```    



<a name="12"/>
</a>

Modelling the Nuclear Envelope against the Ellipsoid
--------------------------------------



Prepare for the modelling of the surface


As these are memory intensive operations, need to clear a few variables
before proceeding

``` {.codeinput}

clear x3d y3d z3d F
cell_v_Ellipse = 2*Hela_nuclei3(:,:,1:levs)+eqEllip(:,:,1:levs);
```

Calculation of the Jaccard Index, for the case of the bioArXiv manuscript Jaccard = 0.7184

``` {.codeinput}
jaccardEllipse =  sum(cell_v_Ellipse(:)==3)/sum(cell_v_Ellipse(:)>0);
```


Extract surface of the cell vs the ellipse once it has been adapted to have more parallels

``` {.codeinput}
counterSlice=round(0.5*(northPole+southPole));
imagesc(2*Hela_nuclei3(:,:,counterSlice)+eqEllip(:,:,counterSlice));
hold
```
Place the centroid to locate later on

``` {.codeinput}
cell_v_Ellipse(round(centroid_Cell(2)):round(centroid_Cell(2)),...
    round(centroid_Cell(1)):round(centroid_Cell(1)),:) = 4;
```

``` {.codeinput}
Hela_nuclei4 = single(Hela_nuclei3);
Hela_nuclei4(round(centroid_Cell(2))-1:round(centroid_Cell(2))+1,...
    round(centroid_Cell(1))-1:round(centroid_Cell(1))+1,:) = 4;
```

Clear the variable as memory is required

``` {.codeinput}
clear Hela_nuclei3
```




Projection of the surface of the cell to 2D

``` {.codeinput}
for counterSlice=3+southPole:min(levs,northPole)
    disp(counterSlice)
    for kAngle=0:179
        %disp(kAngle)
        rotatedImage    = imrotate(Hela_nuclei4(:,:,counterSlice),kAngle,'nearest','crop');
        rotatedEllipse  = imrotate(eqEllip(:,:,counterSlice),kAngle,'nearest','crop');
        % Locate the centroid, as it can move
        [rr2,cc2]       = find(rotatedImage==4);
        rr              = round(median(rr2));
        cc              = round(median(cc2));
        firstElement    = find(rotatedImage(rr,:),1,'first');
        lastElement     = find(rotatedImage(rr,:),1,'last');
        firstElementE   = find(rotatedEllipse(rr,:),1,'first');
        lastElementE    = find(rotatedEllipse(rr,:),1,'last');
        surfaceCell(counterSlice-southPole+1,1+kAngle) =  firstElementE - firstElement ;
        surfaceCell(counterSlice-southPole+1,180+kAngle) =  lastElement - lastElementE ;
    end
end
```

Display distance from Ellipse for one slice of the data
``` {.codeinput}
centreSlice=round(0.5*(northPole+southPole));
figure
plot(surfaceCell(centreSlice,:),'b-','linewidth',2)
grid on
axis tight
xlabel('Angle','fontsize',20)
ylabel('Distance from Ellipse','fontsize',20)
```
![](Figures/Hela_Ellipse_Comparison_Line.png)

Display the surface with a combined colormap that highlights the negative and positive areas
``` {.codeinput}
figure
a                       = hot;
b                       = a(end:-1:1,end:-1:1);
handleSurf              = surf(surfaceCell);
handleSurf.EdgeColor    = 'none';
colormap([a;b])
```


![](Figures/Hela_Surface_RotateB.gif)


\
[Published with MATLAB®
R2017a](http://www.mathworks.com/products/matlab/)\
:::
