function [Button_Scores, change_log,f_means] = GetScoresUpdateB(N_Arms, Change_Rng, Initialize)
    persistent means so_means prs_change_log
    
    if ~exist("Initialize", "var"); Initialize = false; end
    
    if Initialize || isempty(means) || isempty(so_means) || isempty(prs_change_log)
        % Initialize means ensuring they stay within [1, 100]
        means = [randi([1, 100], 1, N_Arms - 1), randi([75,100], 1, 1)];
        
        % Sort means to identify the highest ones
        so_means = sort(means, 'ascend');
        disp(so_means)
        
        prs_change_log = false(N_Arms, 1); % Initialize change log as false
    else
        change_log_entry = false(N_Arms, 1);
        % Update the means of the arms based on the given probability
        for arm = 1:N_Arms
            if rand() < Change_Rng / 100
                % Redraw the means within specified ranges
                if arm < N_Arms
                    means(arm) = randi([1, 100]);
                else
                    means(arm) = randi([75, 100]);
                end
                change_log_entry(arm) = true;
            end
        end

        % Sort means to identify the highest ones
        so_means = sort(means, 'ascend');  
        prs_change_log = [prs_change_log, change_log_entry];
    end

    % Generate new points from specified distributions
   new_points = zeros(1, N_Arms);
for arm = 1:N_Arms
    valid_point = false; % Flag to check if the point is valid
    while ~valid_point
        if arm <= N_Arms - 2
            new_points(arm) = floor(normrnd(so_means(arm), 7));
        elseif arm == N_Arms - 1
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
   Button_Scores([3, 4]) = Button_Scores([4, 3]);
   
   
    f_means=means;
    % Return the change log
    change_log = prs_change_log;
end
