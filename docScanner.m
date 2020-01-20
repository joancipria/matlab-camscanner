%-------------------------
%--- Document Scanner ----
%-------------------------
clear; clc;

% Añadimos funciones
addpath('src/');

% Leemos imagen
image = readImage('test1.jpg');
originalImage = image;
figure, imshow(image);

% Aplicamos el preprocesado (y convertimos a binaria)
image = preprocessing(image);

% Detectamos las esquinas
corners = detectCorners(image);

% Corregimos perspectiva
image = fixPerspective(originalImage, corners);

% Mostramos imagen
figure, imshow(image);