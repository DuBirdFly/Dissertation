function i_gaos = f_gauss(I)

    [ROW,COL] = size(I);

    i_gaos = uint8(f_conv(I,[1 2 1; 2 4 2; 1 2 1]) / 16);

    i_gaos(1,:)       = uint8(I(1,:)      );
    i_gaos(ROW - 1,:) = uint8(I(ROW - 1,:));
    i_gaos(:,1)       = uint8(I(:,1)      );
    i_gaos(:,COL)     = uint8(I(:,COL)    );

end