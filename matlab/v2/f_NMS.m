function o_NMS = f_NMS(I, Gx, Gy)
% 非极大值抑制FPGA优化版 (Non-Maximum Suppression FPGA Plus)
    [ROW,COL] = size(I);
    o_NMS = uint8(zeros(ROW,COL));   % NMS = Non-Maximum Suppression,非极大值抑制

    for r = 2:ROW-1
        for c = 2:COL-1
            p = f_get_px9(I,r,c);
            if  (abs(Gx(r,c))*2 > abs(Gy(r,c))*5 && p(5) >= p(4) && p(5) >= p(6)) ||...
                (abs(Gy(r,c))*2 > abs(Gx(r,c))*5 && p(5) >= p(2) && p(5) >= p(8))
                o_NMS(r,c) = p(5);
            elseif  (((Gx(r,c)>0 && Gy(r,c)>0) || (Gx(r,c)<0 && Gy(r,c)<0)) && p(5) >= p(1) && p(5) >= p(9)) ||...
                    (((Gx(r,c)>0 && Gy(r,c)<0) || (Gx(r,c)<0 && Gy(r,c)>0)) && p(5) >= p(3) && p(5) >= p(7))
                o_NMS(r,c) = p(5);
            else
                o_NMS(r,c) = 0;
            end
        end
    end

end