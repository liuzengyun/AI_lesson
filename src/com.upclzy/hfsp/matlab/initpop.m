function pop= initpop(popsize, piecesize)
%   初始化种群
%   popsize     input 种群规模
%   piecesize   input 工件数量
%   pop         output 种群
pop =zeros(popsize, piecesize);
for i =1:popsize
    pop(i, :) = randperm(piecesize);
end
end