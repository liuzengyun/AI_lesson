function [rl,ru] = makerlru(maxnum)
%   制作两个随机整数， rl < ru
%   maxnum  input  最大数
%   rl      output 小随机数
%   ru      output 大随机数
r1 =randi(maxnum);
r2 =randi(maxnum);
while r2 ==r1
r2 = randi(maxnum);
end
rl = min([r1,r2]);
ru = max([r1,r2]);
end