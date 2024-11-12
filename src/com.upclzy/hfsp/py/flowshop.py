import argparse
import numpy as np, pandas as pd
import time
import copy
import os
import pandas as pd

# 设置超参
parser = argparse.ArgumentParser()
parser.add_argument('--file', default='data.txt', type=str)
parser.add_argument('--population', default=200, type=int)
parser.add_argument('--machine', default=2, type=int)
parser.add_argument('--crossover_rate', default=0.6, type=float)
parser.add_argument('--mutation_rate', default=0.05, type=float)
parser.add_argument('--num_mutation_jobs', default=2, type=float)
parser.add_argument('--iteration', default=100, type=int)




def read_file(file_name):
    data_csv = pd.read_csv(file_name, header=None)  # 假设没有标题行
    rows = data_csv.values.tolist()

    gl = -1  # 初始化，表示未找到实例行
    num_process = 0
    num_job = 0
    data_new = None

    for i, row in enumerate(rows):
        row_str = ' '.join(map(str, row))  # 将行转换为字符串，方便分割
        data = row_str.split()

        if data[0] == "instance" and int(data[1]) == 1:
            gl = i
        elif i == gl + 1:
            num_job = int(data[0])
            num_process = int(data[1])
            data_new = [[0] * num_process for _ in range(num_job)]  # 使用列表推导式创建二维列表
        elif gl != -1 and i > gl + 1 and i < gl + num_job + 2:
            for j in range(num_process):
                data_new[i - gl - 2][j] = int(data[j])

    return data_new, num_process, num_job

#交叉 返回变换结束和变换之前的
def crossover(population_list, population, crossover_rate, num_job):
    parent_list = copy.deepcopy(population_list)
    offspring_list = copy.deepcopy(population_list)

    # 生成一个随机序列，选择要交叉的父染色体
    S = list(np.random.permutation(population))

    for m in range(int(population / 2)):
        crossover_prob = np.random.rand() #0~1随机数
        if crossover_rate >= crossover_prob:  #crossover_rate交叉概率
            parent_1 = population_list[S[2 * m]][:]
            parent_2 = population_list[S[2 * m + 1]][:]
            child_1 = ['na' for i in range(num_job)]
            child_2 = ['na' for i in range(num_job)]
            fix_num = round(num_job / 2)
            g_fix = list(np.random.choice(num_job, fix_num, replace=False)) #从num_job里取出fix_num个

            # 单点交叉，以fix_num为Cutting Point,为避免非法重复，子代在Cutting Point之后的顺序由另一父辈对应顺序决定。
            for g in range(fix_num):
                child_1[g_fix[g]] = parent_2[g_fix[g]]
                child_2[g_fix[g]] = parent_1[g_fix[g]]
            c1 = [parent_1[i] for i in range(num_job) if parent_1[i] not in child_1]
            c2 = [parent_2[i] for i in range(num_job) if parent_2[i] not in child_2]
            for i in range(num_job - fix_num): #把剩余的放进去
                child_1[child_1.index('na')] = c1[i]
                child_2[child_2.index('na')] = c2[i]
            offspring_list[S[2 * m]] = child_1[:]
            offspring_list[S[2 * m + 1]] = child_2[:]

    return offspring_list, parent_list


def mutation(offspring_list, mutation_rate, num_job, num_mutation_jobs):
    # 突变job数量
    for m in range(len(offspring_list)):
        mutation_prob = np.random.rand()
        if mutation_rate >= mutation_prob:
            # 随机选出要变异的任务
            m_chg = list(np.random.choice(num_job, num_mutation_jobs, replace=False))

            # 随机修改两位的基因值
            i = np.random.randint(0, num_mutation_jobs)
            t_value = offspring_list[m][m_chg[i]]
            offspring_list[m][m_chg[i]] = offspring_list[m][m_chg[num_mutation_jobs - 1 - i]]
            offspring_list[m][m_chg[num_mutation_jobs - 1 - i]] = t_value

    return offspring_list


def cost_time(parent_list, offspring_list, data, num_process, num_job, machine, population):
    total_chromosome = copy.deepcopy(parent_list) + copy.deepcopy(
        offspring_list)  # 将父基因与子基因合在一起
    chrom_fit = []
    for c in range(population * 2):
        wait_time=[0 for _ in range(num_job)]
        gene = copy.deepcopy(total_chromosome[c])
        for j in range(num_process):
            machine_time=[0 for _ in range(machine)] #记录每个machine结束的时间
            for i in range(num_job):
                index=machine_time.index(min(machine_time)) # 找到最空闲的machine
                # 在这个machine上做工件i 的 工序J
                machine_time[index]= max(machine_time[index], wait_time[gene[i]]) + data[gene[i]][j]
                # 记录这个工件i 的完成时间
                wait_time[ gene[i]]=machine_time[index]
            # 每次工序都要重新排序记录优先处理排列顺序
            gene=[idx for idx,value in sorted(enumerate(wait_time), key=lambda x:x[1])]
        total_time=max(machine_time)
            #total_time表示最终的时间消耗
        chrom_fit.append(total_time)
    return chrom_fit, total_chromosome


def selection(population, population_list, chrom_fit, total_chromosome):
    pk, qk = [], []
    # 轮盘赌选择
    chrom_fitness = 1. / np.array(chrom_fit)
    total_fitness = np.sum(chrom_fitness)
    for i in range(population * 2):
        pk.append(chrom_fitness[i] / total_fitness)
    for i in range(population * 2):
        cumulative = 0
        for j in range(0, i + 1):
            cumulative = cumulative + pk[j]
        qk.append(cumulative) #前i个pk求和

    selection_rand = [np.random.rand() for _ in range(population)]  #200个0~1的随机数

    for i in range(population):
        if selection_rand[i] <= qk[0]:
            population_list[i] = copy.deepcopy(total_chromosome[0])
            break
        else:
            for j in range(0, population * 2 - 1):
                if selection_rand[i] > qk[j] and selection_rand[i] <= qk[j + 1]:
                    population_list[i] = copy.deepcopy(total_chromosome[j + 1])
    return population_list


def comparison(population, chrom_fit, total_chromosome, Tbest, Tbest_now, sequence_best):
    for i in range(population * 2):
        if chrom_fit[i] < Tbest_now:
            Tbest_now = chrom_fit[i]
            sequence_now = copy.deepcopy(total_chromosome[i])

    if Tbest_now <= Tbest:
        Tbest = Tbest_now
        sequence_best = copy.deepcopy(sequence_now)
    return sequence_best, Tbest


def main(args):
    if os.path.isfile(args.file): #判断是否为文件

        # 读取实例数据，机器数量，任务数量
        data, num_process, num_job = read_file(args.file) #读取文件例子，返回数据，行数列数
        # GA算法
        Tbest = 2 ** 20
        population_list, sequence_best = [], []  #分别赋值
        # 初始化population个随机job序列，实数编码
        for i in range(args.population): #添加200个乱序的原始job序列
            nxm_random_num = list(np.random.permutation(num_job)) #0~num_job-1的乱序
            population_list.append(nxm_random_num) #添加到list中
        # 迭代寻找最优解
        for n in range(args.iteration): #200
            Tbest_now = 2 ** 20
            offspring_list, parent_list = crossover(population_list, args.population, args.crossover_rate, num_job)
            offspring_list = mutation(offspring_list, args.mutation_rate, num_job, args.num_mutation_jobs)
            chrom_fit, total_chromosome = cost_time(parent_list, offspring_list, data, num_process, num_job, args.machine, args.population)
            population_list = selection(args.population, population_list, chrom_fit, total_chromosome)
            # 找到最好的job序列以及消耗的最短时间
            sequence_best, Tbest = comparison(args.population, chrom_fit, total_chromosome, Tbest, Tbest_now,
                                              sequence_best)

        # 显示结果
        print("optimal sequence", sequence_best)
        print("optimal value:%f" % Tbest)
    else:
        raise (ValueError, "Uknown document")


if __name__ == '__main__':
    args = parser.parse_args()
    main(args)
