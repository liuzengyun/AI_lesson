function gantt = makegantt(ptr, per, equsize)
%   制作加工流程矩阵
%   ptr     input  工件时间记录
%   per     input  工件设备记录
%   equsize input  工序设备数量
%   gantt   output 加工流程矩阵
finaltime =max(max(ptr));
[piecesize,prosize] = size(per);
cumsumequ =cumsum(equsize);
gantt =zeros(sum(equsize), finaltime);
for pro =1:prosize
for i = 1:piecesize
if pro == 1
equ = per(i, pro);
else
equ = cumsumequ(pro - 1) + per(i,pro);
end
starttime = ptr(i, pro*2-1);
endtime = ptr(i, pro*2);
gantt(equ, starttime:endtime) = i;
end
end
end