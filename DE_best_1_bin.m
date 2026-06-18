function [best_m, best_f, conv_curve, final_pop] = DE_best_1_bin(params)
%DE_BEST_1_BIN  差分进化算法（改进算法）
%
%   改进点：将变异基向量由随机个体 m_r1 改为当前种群最优个体 m_best
%   变异: v_i = m_best + F * (m_r2 - m_r3)
%   交叉: u_ij = v_ij  if rc_j < c,  else m_ij
%   选择: 若 f(u_i) < f(m_i)，则 m_i <- u_i
%
%   输入/输出与 DE_rand_1_bin 相同，便于对比实验。

    if isfield(params, 'seed')
        rng(params.seed);
    end

    N       = params.N;
    F       = params.F;
    c       = params.c;
    maxGen  = params.maxGen;
    bounds  = params.bounds;
    points  = params.points;
    weights = params.weights;

    x_min = bounds(1, 1); x_max = bounds(1, 2);
    y_min = bounds(2, 1); y_max = bounds(2, 2);
    dim   = 2;

    pop = zeros(N, dim);
    pop(:, 1) = x_min + (x_max - x_min) * rand(N, 1);
    pop(:, 2) = y_min + (y_max - y_min) * rand(N, 1);

    fit = fitness(pop, points, weights);

    conv_curve = zeros(maxGen, 1);
    [best_f, best_idx] = min(fit);
    best_m = pop(best_idx, :);

    for gen = 1:maxGen
        [~, m_best_idx] = min(fit);
        m_best = pop(m_best_idx, :);

        for i = 1:N
            candidates = setdiff(1:N, i);
            idx = candidates(randperm(length(candidates), 2));
            r2 = idx(1);
            r3 = idx(2);

            m_r2 = pop(r2, :);
            m_r3 = pop(r3, :);
            m_i  = pop(i, :);

            % 改进变异: v_i = m_best + F * (m_r2 - m_r3)
            v_i = m_best + F * (m_r2 - m_r3);

            v_i(1) = max(x_min, min(x_max, v_i(1)));
            v_i(2) = max(y_min, min(y_max, v_i(2)));

            u_i = m_i;
            for j = 1:dim
                rc_j = rand();
                if rc_j < c
                    u_i(j) = v_i(j);
                end
            end

            f_u = fitness(u_i, points, weights);
            if f_u < fit(i)
                pop(i, :) = u_i;
                fit(i)    = f_u;
            end
        end

        [gen_best_f, gen_best_idx] = min(fit);
        conv_curve(gen) = gen_best_f;

        if gen_best_f < best_f
            best_f = gen_best_f;
            best_m = pop(gen_best_idx, :);
        end
    end

    final_pop = pop;
end
