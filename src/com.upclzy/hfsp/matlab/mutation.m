function mpop = mutation(pop, mr)

% 变异，交换两个随即位置的基因

% pop      input  种群

% mr       input  变异概率

% mpop     output 变异后种群

[popsize, piecesize] = size(pop);

mpop = pop;

for i = 1:popsize

    if rand > mr

        continue;

    end

    r1 = randi(piecesize);

    r2 = randi(piecesize);

    temp  = mpop(i, r1);

    mpop(i, r1) = mpop(i, r2);

    mpop(i, r2) = temp;

end

end