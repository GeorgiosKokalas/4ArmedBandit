function [so_means, ra_means, means_ra_idx] = generateMeans2(Arms, Static_Arm)
    static_arm_idx = find(Arms == Static_Arm);
    n_arms = length(Arms);
    % Initialize means ensuring they stay within [1, 100]
    means = [randi([1, 100], 1, n_arms - 1), randi([75,100], 1, 1)];

    % Sort means to identify the highest ones
    so_means = sort(means, 'ascend');
    
    % Randomize the means and store the random order
    means_ra_idx = randperm(length(so_means));
    ra_means = so_means(means_ra_idx);
    
    % Find which mean the Static Arm has and where the highest mean resides
    sa_mean_idx = means_ra_idx(static_arm_idx);
    hi_mean_idx = find(means_ra_idx == max(means_ra_idx));
    
    % If the Static Arm doesn't possess the highest mean swap the values
    if means_ra_idx(static_arm_idx) ~= max(means_ra_idx)
        tmp_idx_hold = means_ra_idx(static_arm_idx);
        tmp_val_hold = ra_means(static_arm_idx);
        means_ra_idx(static_arm_idx) = max(means_ra_idx);
        ra_means(static_arm_idx) = max(ra_means);
        means_ra_idx(hi_mean_idx) = tmp_idx_hold;
        ra_means(hi_mean_idx) = tmp_val_hold;
        disp('a');
    end
end