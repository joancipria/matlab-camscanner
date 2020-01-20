%----------------------------------
%--- Corrección de perspectiva ----
%---------------------------------- 

function image = fixPerspective(image, corners)
    % Array de los 4 puntos moviles
    movingPoints = corners;

    topLeft = movingPoints(1,:);
    topRight = movingPoints(2,:);
    botLeft = movingPoints(4,:);

    % Tamaño final de la imagen

    % Distancia entre TOP LEFT y TOP RIGHT
    finalWidth = round(sqrt((topLeft(:,1)-topRight(:,1)).^2 + (topLeft(:,end)-topRight(:,end)).^2));

    % Distancia entre TOP LEFT y BOTTOM LEFT
    finalHeight = round(sqrt((topLeft(:,1)-botLeft(:,1)).^2 + (topLeft(:,end)-botLeft(:,end)).^2));

    % Array de los 4 puntos fijos (las esquinas de la imagen final)
    fixedPoints=[0 0;finalWidth 0;finalWidth finalHeight;0 finalHeight];

    % Aplicamos transformaci�n de perspectiva
    TFORM = fitgeotrans(movingPoints,fixedPoints,'projective');
    R=imref2d([finalHeight finalWidth],[1 finalWidth],[1 finalHeight]);
    image=imwarp(image,TFORM,'OutputView',R);
end