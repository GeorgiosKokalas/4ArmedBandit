function Button_CScores = GetCScores(N_Arms, Change_Rng, ExclusiveIndex, Initialize)
    persistent means std_devs

    if ~exist("Initialize", "var"); Initialize = false; end

    if Initialize || isempty(means) || isempty(std_devs)
        % Initialize means and standard deviations for the arms
        means = floor(5 + (95-5) * rand(1, N_Arms));   % Random means between 5 and 95
        std_devs = randi([1, 3], 1, N_Arms);    % Random std devs chosen from 1, 2, or 3
    else
        % Update the means of the arms based on the given probability
        for arm = 1:N_Arms
            % Determine if the arm's mean should change
            if rand() < Change_Rng
                means(arm) = floor(5 + (95-5) * rand());
                
                % Check if the arm is exclusive to one player
                if ismember(arm, ExclusiveIndex)
                    % Get the other exclusive arm's index
                    other_exclusive_arm = ExclusiveIndex(ExclusiveIndex ~= arm);
                    
                    % Update the mean of the exclusive arm using normal distribution
                    % with median being the mean of the other exclusive arm
                    median_mean = means(other_exclusive_arm);
                    means(arm) = round(median_mean + std_devs(arm) * randn());
                end
            end
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

    Button_CScores = rewards;
end
