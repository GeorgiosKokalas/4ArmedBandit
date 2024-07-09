function Button_ScoresJD = GetJDScores(N_Arms, Change_Rng, ExclusiveIndex, Initialize)
  persistent means std_devs correlation_matrix

    if ~exist("Initialize", "var"); Initialize = false; end

    if Initialize || isempty(means) || isempty(std_devs) || isempty(correlation_matrix)
        % Initialize means and standard deviations for the arms
        means = floor(5 + (95-5) * rand(1, N_Arms));   % Random means between 5 and 95
        std_devs = randi([1, 3], 1, N_Arms);    % Random std devs chosen from 1, 2, or 3
        
        % Ensure the exclusive arms have initial means within a tighter range
        exclusive_mean = floor(5 + (95-5) * rand());
        means(ExclusiveIndex(1)) = exclusive_mean + floor((rand() - 0.5) * 10); % Tight range around the initial mean
        means(ExclusiveIndex(2)) = exclusive_mean + floor((rand() - 0.5) * 10);
        
        % Define the correlation matrix for the exclusive arms
        correlation_matrix = eye(N_Arms);
        correlation_matrix(ExclusiveIndex(1), ExclusiveIndex(2)) = 0.8; % Desired correlation
        correlation_matrix(ExclusiveIndex(2), ExclusiveIndex(1)) = 0.8; % Symmetric correlation
    else
        % Determine if any of the exclusive arms should change their mean
        update_exclusive = false;
        for arm = ExclusiveIndex
            if rand() < Change_Rng
                update_exclusive = true;
                break;
            end
        end
        
        % Update the means of the arms based on the given probability
        for arm = 1:N_Arms
            % Independent update for non-exclusive arms
            if ~ismember(arm, ExclusiveIndex) && rand() < Change_Rng
                means(arm) = floor(5 + (95-5) * rand());
            end
        end
        
        % Joint update for exclusive arms
        if update_exclusive
            mu = [means(ExclusiveIndex(1)), means(ExclusiveIndex(2))];
            % Use smaller standard deviations to keep the means closer
            smaller_std_devs = std_devs(ExclusiveIndex) * 0.5;
            cov_matrix = [smaller_std_devs(1)^2, correlation_matrix(ExclusiveIndex(1), ExclusiveIndex(2)) * smaller_std_devs(1) * smaller_std_devs(2); ...
                          correlation_matrix(ExclusiveIndex(2), ExclusiveIndex(1)) * smaller_std_devs(1) * smaller_std_devs(2), smaller_std_devs(2)^2];

            new_means = mvnrnd(mu, cov_matrix);
            means(ExclusiveIndex(1)) = round(new_means(1));
            means(ExclusiveIndex(2)) = round(new_means(2));
        end
    end

    % Generate rewards
    rewards = zeros(1, N_Arms);
    for arm = 1:N_Arms
        % Generate rewards for each arm based on updated means
        rewards(arm) = round(means(arm) + std_devs(arm) * randn());
        
        % Clamp the rewards to be within the range [1, 100]
        rewards(arm) = max(1, min(100, rewards(arm)));
    end

    Button_ScoresJD = rewards;
end
