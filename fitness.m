function f = fitness(m, points, weights)
%FITNESS 计算快递驿站选址目标函数（加权距离总和）
%   m       - 个体位置 [x, y] 或 N×2 矩阵（每行一个个体）
%   points  - 服务区域坐标，10×2 矩阵，第 i 行为 (x_i, y_i)
%   weights - 日均需求量 w_i，10×1 向量
%
%   f(x,y) = sum_{i=1}^{10} w_i * sqrt((x-x_i)^2 + (y-y_i)^2)

    if size(m, 1) == 1
        x = m(1);
        y = m(2);
        dx = x - points(:, 1);
        dy = y - points(:, 2);
        f = sum(weights .* sqrt(dx.^2 + dy.^2));
    else
        nPop = size(m, 1);
        f = zeros(nPop, 1);
        for k = 1:nPop
            f(k) = fitness(m(k, :), points, weights);
        end
    end
end
