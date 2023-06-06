function p = f_get_px9(I,r,c)
    p = zeros(9,1);
    p(1) = I(r-1,c-1); p(2) = I(r-1,c); p(3) = I(r-1,c+1);
    p(4) = I(r  ,c-1); p(5) = I(r  ,c); p(6) = I(r  ,c+1);
    p(7) = I(r+1,c-1); p(8) = I(r+1,c); p(9) = I(r+1,c+1);
end