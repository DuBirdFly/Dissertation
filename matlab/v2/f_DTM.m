function img = f_DTM(I, Th, Tl)
    % DTM = 双阈值边缘检测(Double threshold monitoring)
    [ROW,COL] = size(I);
    img = false(ROW,COL);   

    for r = 2:ROW-1
        for c = 2:COL-1
            p = f_get_px9(I,r,c);
            z_min = min([p(1) p(2) p(3) p(4) p(6) p(7) p(8) p(9)]);
            if  (p(5) > Th) ||...
                (p(5) > Tl && p(5) < Th && z_min > Th)
                img(r,c) = 1;
            else
                img(r,c) = 0;
            end
        end
    end

end