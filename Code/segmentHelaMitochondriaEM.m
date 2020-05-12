function [mitochondria] = segmentHelaMitochondriaEM(cellRegion,nucleiHela,Hela,avNucleiIntensity,envelopeIntensity)

filtG                                       = gaussF(5,5,1);
Hela_LPF                                    = imfilter(Hela,filtG,'replicate');
 %%
 Hela_LPF(imdilate(cellRegion==0,ones(9)))  = avNucleiIntensity;
 Hela_LPF(imdilate(nucleiHela==1,ones(9)))  = avNucleiIntensity;
 Hela_LPF(Hela_LPF>(Background_intensity-10)) = avNucleiIntensity;
 %%
 darkRegions                                = bwlabel( Hela_LPF<(avNucleiIntensity*0.1+0.9*envelopeIntensity));
 darkRegions_R                              = regionprops(darkRegions,'Area','Eccentricity','solidity');
 %%
 [darkRegions_large,numL]                   = bwlabel( ismember (darkRegions,find(([darkRegions_R.Area]>200).*([darkRegions_R.Eccentricity]<0.97)   )));
 darkRegions_large_R                        = regionprops(darkRegions_large,'Area','Eccentricity','solidity','MajoraxisLength','MinoraxisLength','Eccentricity');
 
 
 %%
 temp                                       = zeros(size(darkRegions));
 structEl = strel('disk',8);
 for counterR = 1:numL
     temp                                   = temp + counterR*(imclose(darkRegions_large==counterR,structEl));
 end
   %%  
 darkRegions_large2                         = bwlabel( imopen(temp,strel('disk',3)));
% darkRegions_large3     = 
 darkRegions_R2                             = regionprops(darkRegions_large2,'Area','Eccentricity','solidity','MajoraxisLength','MinoraxisLength','Eccentricity');
 [darkRegions_large3,numL]                  = bwlabel( ismember (darkRegions_large2,find(([darkRegions_R2.Area]>800))   ));
 %%

 
filtG                                       = gaussF(3,3,1);
%Hela_LPF                                    = imfilter(Hela,filtG,'replicate');

Hela_Edges                                  = edge(Hela,'canny',[],2.5);

Mitochondria_0                              = imfill(darkRegions_large3,'holes');
Mitochondria_1                              = (edge((Mitochondria_0>0).*Hela,'canny',[],2.5));

%imagesc(51*(darkRegions_large3>0)+Hela_LPF)
 %imagesc((Mitochondria_0>0).*Hela_LPF)
 imagesc(Mitochondria_1+Mitochondria_0)
 
 % Candidate for Mito
 
 mitochondria                       = darkRegions_large3;