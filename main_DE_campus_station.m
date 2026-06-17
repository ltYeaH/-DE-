%% 基于差分进化算法的校园快递驿站选址优化 — 主程序
%  算法: DE/rand/1/bin
%  独立运行 20 次，输出收敛曲线、最优个体及统计结果
%
%  参数命名与报告一致:
%    m_i   - 第 i 个个体 (m_i1, m_i2) = (x, y)
%    N     - 种群规模
%    F     - 尺度参数
%    c     - 交叉率
%    v_i   - 变异向量
%    u_i   - 试验向量
%
%  运行方式: 在 MATLAB 命令窗口执行 main_DE_campus_station

clear; clc; close all;

%% ========== 1. 问题数据（表格 1） ==========
points = [  5, 12;   % 服务区域坐标 (x_i, y_i)
           10, 25;
           15,  8;
           18, 20;
           22,  5;
           25, 18;
           30, 10;
           32, 28;
           38, 15;
           42, 25];

weights = [120; 180; 100; 150; 80; 160; 140; 110; 170; 190];  % w_i

%% ========== 2. 算法参数 ==========
params.N       = 30;        % 种群规模 n
params.F       = 0.5;       % 尺度参数 F
params.c       = 0.9;       % 交叉率 c
params.maxGen  = 50;        % 单次运行最大进化代数（迭代终止条件：20 代）
params.bounds  = [0, 50;     % x 范围: 0 <= x <= 50
                  0, 30];    % y 范围: 0 <= y <= 30
params.points  = points;
params.weights = weights;

numRuns = 20;               % 独立运行次数（课程要求不少于 20 次）

%% ========== 3. 独立运行 20 次 ==========
fprintf('========== 差分进化 DE/rand/1/bin ==========\n');
fprintf('种群规模 N = %d, F = %.2f, c = %.2f, 最大代数 = %d\n', ...
    params.N, params.F, params.c, params.maxGen);
fprintf('独立运行次数: %d\n\n', numRuns);

best_m_all   = zeros(numRuns, 2);       % 每次运行的最优个体
best_f_all   = zeros(numRuns, 1);       % 每次运行的最优适应度
conv_all     = zeros(params.maxGen, numRuns);  % 收敛曲线矩阵

for run = 1:numRuns
    params.seed = run;  % 不同随机种子保证独立运行
    [best_m, best_f, conv_curve, ~] = DE_rand_1_bin(params);

    best_m_all(run, :) = best_m;
    best_f_all(run)    = best_f;
    conv_all(:, run)   = conv_curve;

    fprintf('第 %2d 次运行: m* = (%.4f, %.4f), f(m*) = %.4f\n', ...
        run, best_m(1), best_m(2), best_f);
end

%% ========== 4. 统计结果 ==========
f_mean = mean(best_f_all);
f_std  = std(best_f_all);
f_best = min(best_f_all);
f_worst = max(best_f_all);
[global_best_f, idx_best_run] = min(best_f_all);
global_best_m = best_m_all(idx_best_run, :);

fprintf('\n========== 20 次运行统计结果 ==========\n');
fprintf('最优适应度 f*        = %.6f\n', f_best);
fprintf('平均适应度 f_mean    = %.6f\n', f_mean);
fprintf('标准差 sigma         = %.6f\n', f_std);
fprintf('最差适应度 f_worst   = %.6f\n', f_worst);
fprintf('全局最优个体 m*      = (%.6f, %.6f)  [第 %d 次运行]\n', ...
    global_best_m(1), global_best_m(2), idx_best_run);

%% ========== 5. 绘制收敛曲线 ==========
figure('Name', '适应度收敛曲线', 'NumberTitle', 'off');

% 5.1 单次最优运行的收敛曲线
subplot(2, 1, 1);
plot(1:params.maxGen, conv_all(:, idx_best_run), 'b-', 'LineWidth', 1.5);
xlabel('进化代数', 'FontSize', 11);
ylabel('最优适应度 f(m*)', 'FontSize', 11);
title(sprintf('第 %d 次运行收敛曲线（全局最优）', idx_best_run), 'FontSize', 12);
grid on;

% 5.2 20 次运行的平均收敛曲线 ± 标准差
subplot(2, 1, 2);
conv_mean = mean(conv_all, 2);
conv_std  = std(conv_all, 0, 2);
gens = (1:params.maxGen)';

fill([gens; flipud(gens)], ...
     [conv_mean - conv_std; flipud(conv_mean + conv_std)], ...
     [0.85 0.92 1.0], 'EdgeColor', 'none');
hold on;
plot(gens, conv_mean, 'r-', 'LineWidth', 2);
xlabel('进化代数', 'FontSize', 11);
ylabel('最优适应度 f(m*)', 'FontSize', 11);
title('20 次独立运行平均收敛曲线（阴影为 ±1 标准差）', 'FontSize', 12);
legend('±1 标准差', '平均值', 'Location', 'best');
grid on;
hold off;

saveas(gcf, 'convergence_curve.png');
fprintf('\n收敛曲线已保存: convergence_curve.png\n');

%% ========== 6. 绘制最优驿站位置图 ==========
figure('Name', '最优快递驿站位置', 'NumberTitle', 'off');
hold on;

% 需求点（大小与权重成正比）
scatter(points(:,1), points(:,2), weights*0.5, 'b', 'filled', 'DisplayName', '服务区域');
for i = 1:size(points, 1)
    text(points(i,1)+0.8, points(i,2)+0.8, sprintf('%d', i), 'FontSize', 9);
end

% 最优驿站位置
plot(global_best_m(1), global_best_m(2), 'rp', 'MarkerSize', 18, ...
    'MarkerFaceColor', 'r', 'DisplayName', '最优驿站');

% 连线显示加权配送关系
for i = 1:size(points, 1)
    plot([global_best_m(1), points(i,1)], [global_best_m(2), points(i,2)], ...
        'k--', 'LineWidth', 0.5, 'Color', [0.6 0.6 0.6]);
end

xlim([0 50]); ylim([0 30]);
xlabel('X 坐标', 'FontSize', 11);
ylabel('Y 坐标', 'FontSize', 11);
title(sprintf('最优驿站位置 (%.2f, %.2f), f* = %.4f', ...
    global_best_m(1), global_best_m(2), global_best_f), 'FontSize', 12);
legend('Location', 'best');
grid on;
axis equal;
hold off;

saveas(gcf, 'best_station_location.png');
fprintf('最优位置图已保存: best_station_location.png\n');

%% ========== 7. 保存实验数据 ==========
results.numRuns      = numRuns;
results.params       = params;
results.best_m_all   = best_m_all;
results.best_f_all   = best_f_all;
results.conv_all     = conv_all;
results.f_mean       = f_mean;
results.f_std        = f_std;
results.f_best       = f_best;
results.global_best_m = global_best_m;
results.global_best_f = global_best_f;

save('DE_results.mat', 'results');
fprintf('实验数据已保存: DE_results.mat\n');

%% ========== 8. 导出 20 次运行结果到 CSV ==========
T = table((1:numRuns)', best_m_all(:,1), best_m_all(:,2), best_f_all, ...
    'VariableNames', {'Run', 'x_star', 'y_star', 'f_star'});
writetable(T, 'DE_20runs_results.csv');
fprintf('20 次运行结果已导出: DE_20runs_results.csv\n');
