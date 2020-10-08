function cpop = crossover(pop, cr)
%   交叉
%   pop     input  种群
%   cr      input  交叉概率
%   cpop    output 交叉后种群
[popsize, piecesize] = size(pop);
cpop = pop;
if mod(popsize,2) ~= 0
    nn = popsize - 1;
else
    nn = popsize;
end
% 父代father mother, 子代son daughter
% 在rl:ru中，son继承mother，daughter继承father
% 其余位置son继承father，daughter继承mother
for i = 1:2:nn
    if rand > cr
        continue;
    end
    [rl, ru] =makerlru(piecesize);
    father = pop(i, :);
    mother = pop(i+1, :);
    if father == mother
        continue;
    end
    son = zeros(1, piecesize);
    daughter = zeros(1,piecesize);
    son(rl:ru) = mother(rl:ru);
    daughter(rl:ru) =father(rl:ru);
    j = 1;
    for k = 1:piecesize
        if k >= rl &&k <= ru
            continue;
        end
        while ~isempty(find(son== father(j), 1))
            j = j + 1;
        end
        son(k) = father(j);
    end
    j = 1;
    for k = 1:piecesize
        if k >= rl &&k <= ru
            continue;
        end
        while~isempty(find(daughter == mother(j), 1))
            j = j + 1;
        end
        daughter(k) = mother(j);
    end
    cpop(i, :) = son;
    cpop(i+1, :) = daughter;
end
end