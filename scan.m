%---------------------
%---- Leer imagen ----
%---------------------
image = imread('test1.jpg');
original = image;

%figure();
imshow(image);
title('Original');


%---------------------
%--- Preprocesado ----
%---------------------

% *** Convertir imagen a escala de grises ***
image = rgb2gray(image);

% *** Thresholding ***
image = imbinarize(image); 

%figure();
imshow(image,[]);
title('Thresholding');

% *** Open ***
seOpenSize = 10;
seOpen = strel('square',seOpenSize);
image = imopen(image,seOpen);

imshow(image,[]);
title('Open');


% *** Fill ***
image = imfill(image,'holes');

imshow(image,[]);
title('Fill');

% *** Close ***
seCloseSize = 50;
seClose = strel('square',seCloseSize);
image = imclose(image,seClose);

imshow(image,[]);
title('Close');

%figure();
imshow(image,[]);
title('Close');

%----------------------------
%--- Detección de bordes ----
%----------------------------

% Detectamos esquinas
corners = detectHarrisFeatures(image);

% Cogemos las 10 más fuertes
cornersNum = 10;
corners = corners.selectStrongest(cornersNum).Location;

% Obtenemos el centro del objeto
props = regionprops(image, 'Centroid');
xyCentroid = vertcat(props.Centroid);

% Nos quedamos con las 4 esquinas más lejanas del centro

% Mostramos las esquinas
imshow(image); hold on;
plot(corners);

%----------------------------------
%--- Corrección de perspectiva ----
%---------------------------------- 

 topLeft = corners(3,:);
 topRight = corners(4,:);
 botRight = corners(1,:);
 botLeft = corners(2,:);
 
 movingPoints = [topLeft; topRight; botRight; botLeft;];

 fixedPoints=[0 0;size(image,1) 0;size(image,1) size(image,2);0 size(image,2)];
 image = imrotate(image,90);

 TFORM = fitgeotrans(movingPoints,fixedPoints,'projective');
R=imref2d(size(image),[1 size(image,2)],[1 size(image,1)]);

imgTransformed=imwarp(original,TFORM,'OutputView',R);
figure, imshow(imgTransformed);
