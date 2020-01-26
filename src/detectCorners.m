%------------------------------
%--- Detección de esquinas ----
%------------------------------ 

% TODO: Que las 4 esquinas mas lejanas tengan
% una separacion minima entre si. A veces al coger las 4
% esquinas mas lejanas no coinciden con las esquinas

function corners = detectCorners(image, method)

    % --- MÉTODO REGIONPROPS ---
    if strcmp(method,'Regionprops') == 1
        corners = regionprops(image,'Extrema');
        assignin('base','stats',corners);

        topLeft = corners.Extrema(8,:);
        topRight = corners.Extrema(2,:);
        botRight = corners.Extrema(4,:);
        botLeft = corners.Extrema(6,:);

        % Mostramos las esquinas
        imshow(image); hold on;
        plot(corners.Extrema(:,1), corners.Extrema(:,end), 'r*', 'LineWidth', 0.5, 'MarkerSize', 9);
    
    % --- MÉTODO MANUAL ---
    else
        % --- Detectamos todas las esquinas ---
        corners = detectMinEigenFeatures(image);

        % Cogemos las 10 mas fuertes
        cornersNum = 10;
        corners = corners.selectStrongest(cornersNum).Location;

        % Obtenemos el centro del objeto
        props = regionprops(image, 'Centroid');
        xyCentroid = vertcat(props.Centroid);

        % --- Obtenemos las 4 esquinas mas lejanas del centro ---
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

        % Nos quedamos con las 4 esquinas mas lejanas 
        [M,I] = maxk(distances,4);
        bestCorners = corners([I],:);

        % Sobreescribimos corners con las 4 esquinas
        corners = bestCorners;


        % --- Clasificamos esquinas ---

        % Primero clasificamos esquinas en LEFT y RIGHT

        % RIGHT (X maxima)
        [rightCorners, indexRightCorners] = maxk(corners(:,1),2);
        rightCorners = corners(indexRightCorners,:);

        % LEFT (X minima)
        [leftCorners, indexLeftCorners] = mink(corners(:,1),2);
        leftCorners = corners(indexLeftCorners,:);

        % Luego combinamos con TOP y BOTTOM y sacamos la clasificacion final

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

        % Mostramos las esquinas
        imshow(image); hold on;
        plot(corners(:,1), corners(:,end), 'r*', 'LineWidth', 0.5, 'MarkerSize', 9);
    end

    corners = [topLeft; topRight; botRight; botLeft;];
end