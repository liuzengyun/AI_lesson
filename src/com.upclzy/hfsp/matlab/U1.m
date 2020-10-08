clc,clear,close all

% 设备加工时间
piecetime = [2 4 6; 4 9 2; 4 2 8; 9 5 6; 5 2 7; 9 4 3];
equsize = [2 2 2];                  % 每个工序设备数目
piecesize = size(piecetime, 1);     % 工件数目
prosize = size(piecetime, 2);       % 工序数目
popsize = 200;      % 种群规模
cr = 0.6;          % 交叉概率
mr = 0.05;         % 变异概率
maxgen = 100;      % 迭代次数

bestobjvalue = zeros(1, maxgen);
bestpop = zeros(maxgen, piecesize);
avgobjvalue = zeros(1, maxgen);
bestptr = cell(1, maxgen);
bestper = cell(1, maxgen);
pop = initpop(popsize, piecesize);

for gen = 1:maxgen
    [objvalue, ptr,per] = calobjvalue(pop, piecetime, equsize);
    [bobjvalue,bindex] = min(objvalue);
    bestobjvalue(1,gen) = bobjvalue;
    bestpop(gen, :) =pop(bindex, :);
    avgobjvalue(1,gen) = sum(objvalue) / popsize;
    bestptr{1, gen} =ptr{1, bindex};
    bestper{1, gen} =per{1, bindex};
    fitness= calfitness(objvalue);     % 计算适应度值
    pop =selection(pop, fitness);      % 选择
    pop =crossover(pop, cr);           % 交叉
    pop =mutation(pop, mr);            % 变异
end

[~, finalindex] = min(bestobjvalue);
finalptr = bestptr{1, finalindex};
finalper = bestper{1, finalindex};

Time=['当前最佳时间：',num2str(max(max(finalptr)))];
disp(Time);
Order=['当前最佳顺序：',num2str(bestpop(finalindex, :))];
disp(Order);

% disp(bestpop(finalindex, :));
% gantt = makegantt(finalptr, finalper, equsize);
% figure(1);
% imagesc(gantt);
% colorbar;
% title("加工流程图");
% figure(2);
% plot(1:maxgen, bestobjvalue);
% title("最优时间变化图");
% xlabel("代数"); ylabel("最优时间");
% figure(3);
% plot(1:maxgen, avgobjvalue);
% title("平均时间变化图");
% xlabel("代数"); ylabel("平均时间");