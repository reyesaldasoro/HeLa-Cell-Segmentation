kxy=20;
figure(1)
subplot(2,2,1)
imagesc(1*imerode(Hela_nuclei_xy(:,:,kxy),ones(3))+0*imerode(Hela_nuclei_xz2(:,:,kxy),ones(3))+0*imerode(Hela_nuclei_yz2(:,:,kxy),ones(3)))
title('XY','fontsize',20)
subplot(2,2,2)
imagesc(0*imerode(Hela_nuclei_xy(:,:,kxy),ones(3))+1*imerode(Hela_nuclei_xz2(:,:,kxy),ones(3))+0*imerode(Hela_nuclei_yz2(:,:,kxy),ones(3)))
title('XZ','fontsize',20)
subplot(2,2,3)
imagesc(0*imerode(Hela_nuclei_xy(:,:,kxy),ones(3))+0*imerode(Hela_nuclei_xz2(:,:,kxy),ones(3))+1*imerode(Hela_nuclei_yz2(:,:,kxy),ones(3)))
title('YZ','fontsize',20)

subplot(2,2,4)
imagesc(1*imerode(Hela_nuclei_xy(:,:,kxy),ones(3))+1*imerode(Hela_nuclei_xz2(:,:,kxy),ones(3))+1*imerode(Hela_nuclei_yz2(:,:,kxy),ones(3)))
title('Combined','fontsize',20)

figure(2)
q(:,:,1) = Hela_3D(:,:,kxy)+70*uint8(Hela_background_xy(:,:,kxy));
q(:,:,2) = Hela_3D(:,:,kxy)+70*uint8(Hela_nuclei_3ax(:,:,kxy));
q(:,:,3) = Hela_3D(:,:,kxy);

imagesc(q)
