function [retuen] = f_printTXT(I, file_path)
% file_path 使用单引号，可以使用相对地址
    [ROW,COL] = size(I);

    fid = fopen(file_path,'w+');
    for r = 1:ROW
        for c = 1:COL
            % img_NMS(5)是竖着的第5个而不是横着的,所以使用双参数img_NMS(1,5)
            fprintf(fid,'%02X ',I(r,c));
        end
    end
    fclose(fid);

    retuen = 'finish TXT writing';
end