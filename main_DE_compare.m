%% DE/rand/1/bin 与 DE/best/1/bin 对比实验
%  原始算法 vs 改进算法，各独立运行 20 次
%  运行: main_DE_compare

clear; clc; close all;

script_dir = fileparts(mfilename('fullpath'));
if ~isempty(script_dir)
    cd(script_dir);
end

%% 问题数据
points = [  5, 12;
           10, 25;
           15,  8;
           18, 20;
           22,  5;
           25, 18;
           30, 10;
           32, 28;
           38, 15;
           42, 25];
weights = [120; 180; 100; 150; 80; 160; 140; 110; 170; 190];

%% 统一参数（与基准实验一致）
params.N       = 30;
params.F       = 0.5;
params.c       = 0.9;
params.maxGen  = 50;
params.bounds  = [0, 50; 0, 30];
params.points  = points;
params.weights = weights;

numRuns = 20;

%% 存储结果
res_rand.best_m   = zeros(numRuns, 2);
res_rand.best_f   = zeros(numRuns, 1);
res_rand.conv     = zeros(params.maxGen, numRuns);
res_rand.time_s   = zeros(numRuns, 1);
res_rand.conv_gen = zeros(numRuns, 1);

res_best.best_m   = zeros(numRuns, 2);
res_best.best_f   = zeros(numRuns, 1);
res_best.conv     = zeros(params.maxGen, numRuns);
res_best.time_s   = zeros(numRuns, 1);
res_best.conv_gen = zeros(numRuns, 1);

fprintf('========== 原始 vs 改进 对比实验 ==========\n');
fprintf('原始: DE/rand/1/bin | 改进: DE/best/1/bin\n');
fprintf('N=%d, F=%.2f, c=%.2f, maxGen=%d, 独立运行=%d\n\n', ...
    params.N, params.F, params.c, params.maxGen, numRuns);

for run = 1:numRuns
    params.seed = run;

    tic;
    [m1, f1, c1, ~] = DE_rand_1_bin(params);
    res_rand.time_s(run) = toc;
    res_rand.best_m(run, :) = m1;
    res_rand.best_f(run)    = f1;
    res_rand.conv(:, run)   = c1;
    res_rand.conv_gen(run)  = estimate_conv_gen(c1);

    tic;
    [m2, f2, c2, ~] = DE_best_1_bin(params);
    res_best.time_s(run) = toc;
    res_best.best_m(run, :) = m2;
    res_best.best_f(run)    = f2;
    res_best.conv(:, run)   = c2;
    res_best.conv_gen(run)  = estimate_conv_gen(c2);

    fprintf('Run %2d | rand: f=%.6f, conv=%2d gen | best: f=%.6f, conv=%2d gen\n', ...
        run, f1, res_rand.conv_gen(run), f2, res_best.conv_gen(run));
end

%% 统计汇总
stats = struct();
stats.rand.f_star    = min(res_rand.best_f);
stats.rand.f_mean    = mean(res_rand.best_f);
stats.rand.f_std     = std(res_rand.best_f);
stats.rand.f_worst   = max(res_rand.best_f);
stats.rand.conv_mean = mean(res_rand.conv_gen);
stats.rand.time_mean = mean(res_rand.time_s);

stats.best.f_star    = min(res_best.best_f);
stats.best.f_mean    = mean(res_best.best_f);
stats.best.f_std     = std(res_best.best_f);
stats.best.f_worst   = max(res_best.best_f);
stats.best.conv_mean = mean(res_best.conv_gen);
stats.best.time_mean = mean(res_best.time_s);

[~, idx_r] = find(res_rand.best_f == stats.rand.f_star, 1, 'first');
[~, idx_b] = find(res_best.best_f == stats.best.f_star, 1, 'first');
stats.rand.global_m = res_rand.best_m(idx_r, :);
stats.best.global_m = res_best.best_m(idx_b, :);

fprintf('\n========== 对比统计 ==========\n');
fprintf('%-28s %14s %14s\n', '指标', 'DE/rand/1/bin', 'DE/best/1/bin');
fprintf('%-28s %14.6f %14.6f\n', '最优值 f*', stats.rand.f_star, stats.best.f_star);
fprintf('%-28s %14.6f %14.6f\n', '平均值 f_mean', stats.rand.f_mean, stats.best.f_mean);
fprintf('%-28s %14.6f %14.6f\n', '标准差 sigma', stats.rand.f_std, stats.best.f_std);
fprintf('%-28s %14.2f %14.2f\n', '平均收敛代数', stats.rand.conv_mean, stats.best.conv_mean);
fprintf('%-28s %14.4f %14.4f\n', '平均运行时间(s)', stats.rand.time_mean, stats.best.time_mean);
fprintf('全局最优坐标 m* (rand) = (%.6f, %.6f)\n', stats.rand.global_m(1), stats.rand.global_m(2));
fprintf('全局最优坐标 m* (best) = (%.6f, %.6f)\n', stats.best.global_m(1), stats.best.global_m(2));

%% 平均收敛曲线对比
gens = (1:params.maxGen)';
conv_rand_mean = mean(res_rand.conv, 2);
conv_best_mean = mean(res_best.conv, 2);
conv_rand_std  = std(res_rand.conv, 0, 2);
conv_best_std  = std(res_best.conv, 0, 2);

figure('Name', '原算法与改进算法收敛曲线对比', 'NumberTitle', 'off', 'Position', [100 100 800 500]);

subplot(1, 2, 1);
fill([gens; flipud(gens)], [conv_rand_mean - conv_rand_std; flipud(conv_rand_mean + conv_rand_std)], ...
    [0.85 0.92 1.0], 'EdgeColor', 'none', 'DisplayName', 'rand \pm \sigma');
hold on;
fill([gens; flipud(gens)], [conv_best_mean - conv_best_std; flipud(conv_best_mean + conv_best_std)], ...
    [1.0 0.88 0.88], 'EdgeColor', 'none', 'DisplayName', 'best \pm \sigma');
plot(gens, conv_rand_mean, 'b-', 'LineWidth', 2, 'DisplayName', 'DE/rand/1/bin');
plot(gens, conv_best_mean, 'r-', 'LineWidth', 2, 'DisplayName', 'DE/best/1/bin');
xlabel('进化代数'); ylabel('最优适应度 f(m^*)');
title('20 次平均收敛曲线对比');
legend('Location', 'best'); grid on; hold off;

saveas(gcf, 'compare_convergence.png');
fprintf('\n对比图已保存: compare_convergence.png\n');

%% 导出 CSV
T = table( ...
    (1:numRuns)', res_rand.best_f, res_best.best_f, ...
    res_rand.conv_gen, res_best.conv_gen, ...
    res_rand.time_s, res_best.time_s, ...
    'VariableNames', {'Run', 'f_rand', 'f_best', 'convGen_rand', 'convGen_best', 'time_rand', 'time_best'});
writetable(T, 'DE_compare_20runs.csv');

T2 = table( ...
    {'DE/rand/1/bin'; 'DE/best/1/bin'}, ...
    [stats.rand.f_star; stats.best.f_star], ...
    [stats.rand.f_mean; stats.best.f_mean], ...
    [stats.rand.f_std; stats.best.f_std], ...
    [stats.rand.conv_mean; stats.best.conv_mean], ...
    [stats.rand.time_mean; stats.best.time_mean], ...
    'VariableNames', {'Algorithm', 'f_star', 'f_mean', 'f_std', 'conv_gen_mean', 'time_mean_s'});
writetable(T2, 'DE_compare_summary.csv');
fprintf('结果已导出: DE_compare_20runs.csv, DE_compare_summary.csv\n');

