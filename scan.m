%---------------------
%---- Leer imagen ----
%---------------------
image = imread('test2.jpg');
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

% *** Obtener las 4 esquinas más lejanas del centro ***
% Separamos en X e Y los corners
x = corners(:,1);
y = corners(:,end);

% Calculamos distancias de cada corner respecto al centro
for k = 1 : cornersNum
    d = sqrt((xyCentroid(:,1)-x(k)).^2 + (xyCentroid(:,end)-y(k)).^2);
    %logMsg = [' Centroid at (',num2str(xyCentroid(:,1)),' , ', num2str(xyCentroid(:,end)), ') is at ', num2str(d), ' from point #',num2str(k),' at (',num2str(x(k)),' , ',num2str(y(k)),')'];
    %disp(logMsg)
    [distances(k), indexOfMax(k)] = max(d);
end

% Nos quedamos con las 4 esquinas más lejanas 
[M,I] = maxk(distances,4);
bestCorners = corners([I],:);

% Sobreescribimos corners con las 4 esquinas
corners = bestCorners;

% Mostramos las esquinas
imshow(image); hold on;
plot(corners(:,1), corners(:,end), 'r*', 'LineWidth', 0.5, 'MarkerSize', 9);

%----------------------------------
%--- Corrección de perspectiva ----
%---------------------------------- 

% Detectamos que esquina es cada punto (TODO: debe ser dinámico)
topLeft = corners(3,:);
topRight = corners(4,:);
botRight = corners(1,:);
botLeft = corners(2,:);

% Array de los 4 puntos móviles
movingPoints = [topLeft; topRight; botRight; botLeft;];

% Array de los 4 puntos fijos (las esquinas de la imagen final)
fixedPoints=[0 0;size(image,1) 0;size(image,1) size(image,2);0 size(image,2)];

% Aplicamos transformación de perspectiva
TFORM = fitgeotrans(movingPoints,fixedPoints,'projective');
R=imref2d(size(image),[1 size(image,2)],[1 size(image,1)]);
imgTransformed=imwarp(original,TFORM,'OutputView',R);

% Mostramos imagen
figure, imshow(imgTransformed);
