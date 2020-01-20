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

% TODO: Mejorar el tratamiento para distintas situaciones

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

%------------------------------
%--- Detección de esquinas ----
%------------------------------

% TODO: Que las 4 esquinas más lejanas tengan
% una separación mínima entre sí. A veces al coger las 4
% esquinas más lejanas no coinciden con las esquinas

% --- Detectamos todas las esquinas ---
corners = detectHarrisFeatures(image);

% Cogemos las 10 más fuertes
cornersNum = 10;
corners = corners.selectStrongest(cornersNum).Location;

% Obtenemos el centro del objeto
props = regionprops(image, 'Centroid');
xyCentroid = vertcat(props.Centroid);

% --- Obtenemos las 4 esquinas más lejanas del centro ---
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

% --- Clasificamos esquinas ---

% Primero clasificamos esquinas en LEFT y RIGHT

% RIGHT (X máxima)
[rightCorners, indexRightCorners] = maxk(corners(:,1),2);
rightCorners = corners(indexRightCorners,:);

% LEFT (X mínima)
[leftCorners, indexLeftCorners] = mink(corners(:,1),2);
leftCorners = corners(indexLeftCorners,:);

% Luego combinamos con TOP y BOTTOM y sacamos la clasificación final

% BOTTOM LEFT
[botLeft, indexBotLeft] = maxk(leftCorners(:,end),1);
botLeft = leftCorners(indexBotLeft,:);

% BOTTOM RIGHT
[botRight, indexBotRight] = maxk(rightCorners(:,end),1);
botRight = rightCorners(indexBotRight,:);

% TOP RIGHT
[topRight, indexTopRight] = mink(rightCorners(:,end),1);
topRight = rightCorners(indexTopRight,:);

% TOP LEFT
[topLeft, indexTopLeft] = mink(leftCorners(:,end),1);
topLeft = leftCorners(indexTopLeft,:);


%----------------------------------
%--- Corrección de perspectiva ----
%---------------------------------- 

% Array de los 4 puntos móviles
movingPoints = [topLeft; topRight; botRight; botLeft;];

% Array de los 4 puntos fijos (las esquinas de la imagen final)
fixedPoints=[0 0;size(image,2) 0;size(image,2) size(image,1);0 size(image,1)];

% Aplicamos transformación de perspectiva
TFORM = fitgeotrans(movingPoints,fixedPoints,'projective');
R=imref2d(size(image),[1 size(image,2)],[1 size(image,1)]);
imgTransformed=imwarp(original,TFORM,'OutputView',R);

% Mostramos imagen
figure, imshow(imgTransformed);