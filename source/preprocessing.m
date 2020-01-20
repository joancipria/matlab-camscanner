%---------------------
%--- Preprocesado ----
%---------------------

% TODO: Mejorar el tratamiento para distintas situaciones

function image = preprocessing(image)
    % *** Convertir imagen a escala de grises ***
    imageGS = rgb2gray(image);

    % *** Aplicar una equalizacion de hist adaptativa ***
    imageHEQ = adapthisteq(imageGS);

    % *** Correccion iluminacion ***
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
end