%---------------------
%---- Leer imagen ----
%---------------------

image = imread('test4.jpg');
original = image;
figure, imshow(image);

%---------------------
%--- Preprocesado ----
%---------------------

% TODO: Mejorar el tratamiento para distintas situaciones

% *** Convertir imagen a escala de grises ***
imageGS = rgb2gray(image);

% *** Aplicar una equalizaci�n de hist adaptativa ***
imageHEQ = adapthisteq(imageGS);

% *** Correcci�n iluminaci�n ***
MN = size(imageHEQ);
background = imopen(imageHEQ,strel('rectangle',MN));
I2 = imsubtract(imageHEQ,background);
I3= imadjust(I2);

% *** Imagen binaria ***
level = graythresh(imageGS);
d = imbinarize(I3,level);
bw = bwareaopen(d, 50);

image = bw;

% *** Open ***
seOpenSize = 20;
seOpen = strel('square',seOpenSize);
image = imopen(image,seOpen);

% *** Fill ***
image = imfill(image,'holes');

% *** Close ***
seCloseSize = 50;
seClose = strel('square',seCloseSize);
image = imclose(image,seClose);

BW2 = bwareaopen(image, 4000);

image = BW2;

%------------------------------
%--- Detecci�n de esquinas ----
%------------------------------

% TODO: Que las 4 esquinas m�s lejanas tengan
% una separaci�n m�nima entre s�. A veces al coger las 4
% esquinas m�s lejanas no coinciden con las esquinas

% --- Detectamos todas las esquinas ---
corners = detectMinEigenFeatures(image);

% Cogemos las 10 m�s fuertes
cornersNum = 10;
corners = corners.selectStrongest(cornersNum).Location;

% Obtenemos el centro del objeto
props = regionprops(image, 'Centroid');
xyCentroid = vertcat(props.Centroid);

% --- Obtenemos las 4 esquinas m�s lejanas del centro ---
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

% Nos quedamos con las 4 esquinas m�s lejanas 
[M,I] = maxk(distances,4);
bestCorners = corners([I],:);

% Sobreescribimos corners con las 4 esquinas
corners = bestCorners;

% Mostramos las esquinas
imshow(image); hold on;
plot(corners(:,1), corners(:,end), 'r*', 'LineWidth', 0.5, 'MarkerSize', 9);

% --- Clasificamos esquinas ---

% Primero clasificamos esquinas en LEFT y RIGHT

% RIGHT (X m�xima)
[rightCorners, indexRightCorners] = maxk(corners(:,1),2);
rightCorners = corners(indexRightCorners,:);

% LEFT (X m�nima)
[leftCorners, indexLeftCorners] = mink(corners(:,1),2);
leftCorners = corners(indexLeftCorners,:);

% Luego combinamos con TOP y BOTTOM y sacamos la clasificaci�n final

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
%--- Correcci�n de perspectiva ----
%---------------------------------- 

% Array de los 4 puntos m�viles
movingPoints = [topLeft; topRight; botRight; botLeft;];

% Array de los 4 puntos fijos (las esquinas de la imagen final)
finalWidth = round(sqrt((topLeft(:,1)-topRight(:,1)).^2 + (topLeft(:,end)-topRight(:,end)).^2));
finalHeight = round(sqrt((topLeft(:,1)-botLeft(:,1)).^2 + (topLeft(:,end)-botLeft(:,end)).^2));

fixedPoints=[0 0;finalWidth 0;finalWidth finalHeight;0 finalHeight];

% Aplicamos transformaci�n de perspectiva
TFORM = fitgeotrans(movingPoints,fixedPoints,'projective');
R=imref2d([finalHeight finalWidth],[1 finalWidth],[1 finalHeight]);
imgTransformed=imwarp(original,TFORM,'OutputView',R);

% Mostramos imagen
figure, imshow(imgTransformed);