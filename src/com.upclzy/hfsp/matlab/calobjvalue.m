function [objvalue, ptr, per] = calobjvalue(pop, piecetime,equsize)
% 计算目标函数值
% pop          input  种群
% piecetime    input  工件加工时间
% equsize      input  每个工序设备数量
% objvalue     output 目标函数值（加工时间）
% ptr          output 工件加工时间记录，cell
% per          output 工件加工设备记录，cell
[popsize, piecesize] = size(pop);
prosize = size(equsize, 2);
objvalue = zeros(popsize, 1);
ptr = cell(1, popsize);
per = cell(1, popsize);
for i = 1:popsize
    pieceweight =pop(i, :);
    % 设备状态序列
    % [工序1设备1工序1设备2 工序2设备1 工序2设备2 ……]
    % 记录当前设备使用结束时间，默认为0表示未开始
    equstu = zeros(1,sum(equsize));
    % 对设备状态序列的工序分隔符
    % 大于等于当前设备最小值的索引是当前设备所处的工序
    % [2 35] 工序1有2台设备工序2有1台设备 工序3有2台设备
    prosep =cumsum(equsize);
    % 工件时间记录，记录每个工件每个工序的开始时间和结束时间
    % 行表示工件，相邻两列表示开始加工时间和停止加工时间
    % [1 2 2 3; 4 5 67]
    % 表示工件1第1工序加工时间为1-2，第2工序加工时间为2-3
    % 工件2第1工序加工时间为4-5，第2工序加工时间为6-7
    piecetimerecord =zeros(piecesize, prosize*2);
    % 工件设备记录，记录每个工件在工序中的加工设备
    % 行数表示工件，列表示该零件在每个工序加工设备
    % [1 2; 2 1]
    % 表示工件1在第1工序加工设备为1，第2工序加工设备为2
    % 工件2在第1工序加工设备为2，第2工序加工设备为1
    pieceequrecord =zeros(piecesize, prosize);
    % 对每一道工序
    % 如果是第1道工序，对工件按优先级排序
    % 其余工序上上一道工序完工时间对工件排序
    % 对排序后的每一件工件
    % 对该工序中可用机器按使用结束时间排序
    % 使用使用结束时间最小的机器
    % 加工开始时间为max{设备使用结束时间,零件上一工序完工时间}
    % 加工结束时间=加工开始时间+加工时间
    % 更新各个状态和记录矩阵
    for pro =1:prosize
        if(pro == 1)
            [~,piecelist] = sort(pieceweight);
        else
           tempendtime = piecetimerecord(:, (pro-1)*2);
           tempendtime = tempendtime';
            [~,piecelist] = sort(tempendtime);
        end
        for pieceindex= 1:length(piecelist)
            piece =piecelist(pieceindex);
            equtimelist = equstu(prosep(pro)-equsize(pro)+1:prosep(pro));
            [equtime,equlist] = sort(equtimelist);
            equ =equlist(1);
            if pro ==1
               piecestarttime = 0;
            else
               piecestarttime = piecetimerecord(piece, pro*2-2);
            end
            starttime= max(equtime(1), piecestarttime) + 1;
            endtime =starttime + piecetime(piece, pro) - 1;
            equstuindex = prosep(pro)-equsize(pro)+equ;
            equstu(equstuindex) = endtime;
            piecetimerecord(piece, pro*2-1) = starttime;
            piecetimerecord(piece, pro*2) = endtime;
            pieceequrecord(piece, pro) = equ;
        end
    end
    objvalue(i, 1) =max(max(piecetimerecord));
    ptr{1, i} =piecetimerecord;
    per{1, i} =pieceequrecord;
end
end