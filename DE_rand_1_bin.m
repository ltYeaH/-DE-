function [best_m, best_f, conv_curve, final_pop] = DE_rand_1_bin(params)
%DE_RAND_1_BIN  差分进化算法 DE/rand/1/bin 单次运行
%   变异: v_i = m_r1 + F * (m_r2 - m_r3)
%   交叉: u_ij = v_ij  if rc_j < c,  else m_ij
%   选择: 若 f(u_i) < f(m_i)，则 m_i <- u_i
%   输入 params 结构体字段：
%     N       - 种群规模
%     F       - 尺度参数
%     c       - 交叉率
%     maxGen  - 最大进化代数（迭代终止条件）
%     bounds  - 搜索范围 [x_min, x_max; y_min, y_max]
%     points  - 服务区域坐标 10×2
%     weights - 需求量权重 10×1
%     seed    - 随机种子（可选）
%   输出：
%     best_m     - 最优个体 m* = [x*, y*]
%     best_f     - 最优适应度 f(m*)
%     conv_curve - 每代最优适应度，长度 maxGen
%     final_pop  - 最终种群 N×2

    if isfield(params, 'seed')
        rng(params.seed);
    end

    N      = params.N;
    F      = params.F;
    c      = params.c;
    maxGen = params.maxGen;
    bounds = params.bounds;
    points = params.points;
    weights = params.weights;

    x_min = bounds(1, 1); x_max = bounds(1, 2);
    y_min = bounds(2, 1); y_max = bounds(2, 2);
    dim   = 2;

    % Step 1: 初始化种群 {m_i}，m_i = (m_i1, m_i2)
    pop = zeros(N, dim);
    pop(:, 1) = x_min + (x_max - x_min) * rand(N, 1);
    pop(:, 2) = y_min + (y_max - y_min) * rand(N, 1);

    % Step 2: 计算初始适应度
    fit = fitness(pop, points, weights);

    conv_curve = zeros(maxGen, 1);
    [best_f, best_idx] = min(fit);
    best_m = pop(best_idx, :);

    % Step 3: 进化循环
    for gen = 1:maxGen
        for i = 1:N
            % 随机选取互不相同的 r1, r2, r3，且均不等于 i
            candidates = setdiff(1:N, i);
            idx = candidates(randperm(length(candidates), 3));
            r1 = idx(1);
            r2 = idx(2);
            r3 = idx(3);

            m_r1 = pop(r1, :);
            m_r2 = pop(r2, :);
            m_r3 = pop(r3, :);
            m_i  = pop(i, :);

            % 变异: v_i = m_r1 + F * (m_r2 - m_r3)
            v_i = m_r1 + F * (m_r2 - m_r3);

            % 边界处理：超出可行域则截断到边界
            v_i(1) = max(x_min, min(x_max, v_i(1)));
            v_i(2) = max(y_min, min(y_max, v_i(2)));

            % 交叉: u_ij = v_ij if rc_j < c, else m_ij,  j = 1,2
            u_i = m_i;
            for j = 1:dim
                rc_j = rand();
                if rc_j < c
                    u_i(j) = v_i(j);
                end
            end

            % 选择: 若 f(u_i) < f(m_i)，则 m_i <- u_i
            f_u = fitness(u_i, points, weights);
            f_m = fit(i);
            if f_u < f_m
                pop(i, :) = u_i;
                fit(i)    = f_u;
            end
        end

        % 记录当代最优适应度
        [gen_best_f, gen_best_idx] = min(fit);
        conv_curve(gen) = gen_best_f;

        if gen_best_f < best_f
            best_f = gen_best_f;
            best_m = pop(gen_best_idx, :);
        end
    end

    final_pop = pop;
end
