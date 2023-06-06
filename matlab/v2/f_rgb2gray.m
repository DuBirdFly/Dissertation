function Gray = f_rgb2gray(I)

    R = uint16(I(:,:,1)); 
    G = uint16(I(:,:,2)); 
    B = uint16(I(:,:,3)); 

    % Gray = R*0.299 + G*0.587 + B*0.114;   % 经验参数

    Gray = uint8((R*77 + G*150 + B*29) / 256);  % 定点化近似

end