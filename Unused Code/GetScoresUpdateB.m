function [Button_Scores, change_log,f_means] = GetScoresUpdateB(Arms, Change_Rng, Static_Arm, Initialize)
    persistent means so_means prs_change_log means_ra_idx
    n_arms = length(Arms);
    if ~exist("Initialize", "var"); Initialize = false; end
    
    if Initialize || isempty(means) || isempty(so_means) || isempty(prs_change_log)
        [so_means, means, means_ra_idx] = generateMeans(Arms, Static_Arm);

        
        prs_change_log = false(n_arms, 1); % Initialize change log as false
    else
        change_log_entry = false(n_arms, 1);
        [~, new_means, ~] = generateMeans(Arms, Static_Arm); 
        % Update the means of the arms based on the given probability
        for arm = 1:n_arms
            if rand() < Change_Rng / 100
                means(arm) = new_means(arm);
                change_log_entry(arm) = true;
            end
        end

        % Sort means to identify the highest ones
        so_means = sort(means, 'ascend'); 
        new_means_ra_idx = zeros(1,4);
        same_idx = 1;
        for arm = 1:n_arms
            so_means_idx = find(so_means == means(arm));
            disp(so_means_idx);
            try
                new_means_ra_idx(arm) = so_means_idx(same_idx);
            catch ME
                new_means_ra_idx(arm) = so_means_idx(1);
                disp(ME.message);
            end
            if length(so_means_idx) > 1; same_idx = same_idx + 1; end
           
        end
        disp(new_means_ra_idx);
        means_ra_idx = new_means_ra_idx;
        prs_change_log = [prs_change_log, change_log_entry];
    end

    % Generate new points from specified distributions
    new_points = zeros(1, n_arms);
    for arm_idx = 1:length(means_ra_idx)
        arm = means_ra_idx(arm_idx);
        valid_point = false; % Flag to check if the point is valid
        while ~valid_point
            if arm <= n_arms - 2
                new_points(arm) = floor(normrnd(so_means(arm), 15));
            elseif arm == n_arms - 1
                mu_right = log((so_means(end - 1)^2) / sqrt(15^2 + (so_means(end - 1)^2)));
                sd_right = sqrt(log((15^2) / (so_means(end - 1)^2) + 1));
                new_points(arm) = floor(lognrnd(mu_right, sd_right));
            else
                mu_left = log((so_means(end)^2) / sqrt(15^2 + (so_means(end)^2)));
                sd_left = sqrt(log((15^2) / (so_means(end)^2) + 1));
                lognormal_sample = floor(lognrnd(mu_left, sd_left));
                central_value = 2 * so_means(end);
                new_points(arm) = central_value - lognormal_sample;
            end

            % Check if the generated point is within the valid range
            if new_points(arm) >= 1 && new_points(arm) <= 100
                valid_point = true; % Point is valid
            end
        end
    end

   Button_Scores = new_points;
   
   
    f_means=means;
    % Return the change log
    change_log = prs_change_log;
end

function [so_means, ra_means, means_ra_idx] = generateMeans(Arms, Static_Arm)
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