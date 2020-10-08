function spop = selection(pop, fitness)
% 轮盘赌选择
% pop      input  种群
% fitness  input  适应度值
% spop     output 选择后生成的种群
[popsize, piecesize] = size(pop);
spop = zeros(popsize, piecesize);
sumfit = sum(fitness);
fitness = fitness ./ sumfit;
fitness = cumsum(fitness);
r = rand(1, popsize);
r = sort(r);
j = 1;
for i = 1:popsize
    while fitness(j)< r(i)
        j = j + 1;
    end
    spop(i, :) =pop(j, :);
end
% 由于上面轮盘赌方法特殊性，一个个体在相邻位置多次重复，故随机排序
rr = randperm(popsize);
spop(:, :) = spop(rr, :);
end