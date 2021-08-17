

midregion = (Hela_cell(:,:,k)).*(1-Hela_nuclei(:,:,k)).*...
    imfilter(currSlices(:,:,k),fspecial('Gaussian',3,1));



imagesc(midregion.*(1-edge(midregion,'canny',[],3)))

%imagesc(Hela_background(:,:,k)*20+Hela_cell(:,:,k)*10+...
%    Hela_nuclei(:,:,k)*10+imfilter(currSlices(:,:,k),fspecial('Gaussian',3,1)))
%%
k =   170;
valleys=zeros(size(midregion));
ridges=zeros(size(midregion));
        [Hx, Hy] = gradient(double(imfilter(currSlices(:,:,k),fspecial('Gaussian',11,3))));
        [Hxx, Hxy] = gradient(Hx);
        [Hyx, Hyy] = gradient(Hy);
        valleys=valleys+0.5*(Hxx+Hyy-sqrt(Hxx.^2+4.*Hxy.^2-2.*Hxx.*Hyy+Hyy.^2));
        ridges=ridges+0.5*(Hxx+Hyy+sqrt(Hxx.^2+4.*Hxy.^2-2.*Hxx.*Hyy+Hyy.^2));

ridges_plasma = Hela_cell(:,:,k).*(1-Hela_nuclei(:,:,k)).*(ridges);
        
figure(1)
imagesc(ridges_plasma)
colormap gray
figure(2)
imagesc(Hela_cell(:,:,k).*(1-Hela_nuclei(:,:,k)).*(currSlices(:,:,k)))
colormap gray
%%
figure(3)
imagesc(6*(ridges_plasma>1.77156)+(ridges_plasma))

%%
[fRidges,fStats,netP,dataOut,dataOut2,dataOut3,dataOut4] =  scaleSpaceLowMem(uint8(255-currSlices(500:1300,600:1500,k)),1:20,1.75);

