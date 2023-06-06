function img = f_conv(img_in, convCore)

    [ROW,COL] = size(img_in);
    I = double(img_in);
    cv = f_get_px9(double(convCore),2,2);

    img = zeros(ROW,COL);

    for r = 2:ROW-1
        for c = 2:COL-1
            p = f_get_px9(I,r,c);
            img(r,c) = sum(p.*cv);
        end
    end

end