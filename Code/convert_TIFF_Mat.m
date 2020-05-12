baseDir             = 'D:\Acad\Crick\Hela8000_tiff\';
dir0                = dir(strcat(baseDir,'*tiff'));

filtG               = gaussF(3,3,1);

numImages           = size(dir0,1);

h0                  = figure(1);
 currentImage = imread(dir0(1).name);
    imagesc(imfilter(currentImage,filtG))
h1=gca;
 
hT =    title(num2str(k));
 
%%
% 
% for k=1:10:numImages
%     
%     currentImage = imread(dir0(k).name);
% 
%     %pause(0.01)
%      h1.Children.CData  = imfilter(currentImage,filtG);
%     hT.String           =  (num2str(k));
%     drawnow
% 
% end

%%
clear HeL*
HeLa3d(8192,8192,30)=uint8(0);

for biasSl = 150:30:500
    
    for k=biasSl+(1:30) %numImages
        disp(k)
        currentImage = imread(dir0(k).name);
        HeLa3d(:,:,k-biasSl) = imfilter(currentImage,filtG);
        %h1.Children.CData  = Hela3d(:,:,k);
        % drawnow
    end
   save(strcat('HeLa3D_',num2str(biasSl+1),'_',num2str(biasSl+30),'.mat'),'HeLa3d'  )
 
end