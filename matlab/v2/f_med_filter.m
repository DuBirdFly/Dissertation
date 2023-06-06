function i_med = f_med_filter(I)

    [ROW,COL] = size(I);

    i_med = uint8(zeros(ROW,COL));

    theta1 = 16;
    theta2 = 22;

    for r = 2:ROW-1
        for c = 2:COL-1 
            p = f_get_px9(I, r, c);
            z = zeros(9,1);
            for i = 1:9
                z(i) = abs(p(i) - p(5));    % 9方向（包括自己）的差分数据
            end
            Zavg = mean(z);
            Zmin = min(z);
            if Zavg < theta1                          % 极大可能不是噪点
                i_med(r,c) = p(5);                    % 取本值
            else 
                if (Zavg + Zmin >= theta2)            % 一定是噪点，且大概率是孤立噪点
                    i_med(r,c) = median(p);           % 取中值
                else                                  % 可能是噪点，且8-邻域内疑似还有其他噪点
                    aa = 0;
                    for i = 1:9
                        if (z(i) >= Zavg) 
                            aa = aa + 1;
                        end
                    end
                    if (aa >= 5)                % aa里面1多，说明是噪点
                        i_med(r,c) = median(p);
                    else                        % aa里面0多，说明不是噪点
                        i_med(r,c) = p(5);
                    end
                end
            end
        end
    end

    i_med(1,:)       = I(1,:)      ;
    i_med(ROW - 1,:) = I(ROW - 1,:);
    i_med(:,1)       = I(:,1)      ;
    i_med(:,COL)     = I(:,COL)    ;
end