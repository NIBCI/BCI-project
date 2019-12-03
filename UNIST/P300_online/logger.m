function logger(str, sess)
if nargin < 2
    sess            = 0;
end
fileID              = fopen(sprintf('./DB_log/EXP_LOG_%s.txt',date),'a+');
clk                 = clock;
fprintf(fileID,'\r\n[%02d] %04d-%02d-%02d / %02d:%02d:%02.0f: %s',sess, clk(1),clk(2), clk(3),clk(4), clk(5), clk(6), str);
fclose(fileID);