function run_simulation()
    % Initialize arrays to store rewards for arms 1 and 2
    arm1_rewards = [];
    arm2_rewards = [];

    % Run the simulation for 100 trials
    for t = 1:100
        if t == 1
            %Button_CScores = GetCScores(4, 0.05,[3,4], true);
            Button_ScoresJD = GetJDScores(4, .05, [3,4], true);
        else
            %Button_CScores = GetCScores(4, 0.05, [3,4],false);
            Button_ScoresJD = GetJDScores(4, .05, [3,4], false);
        end
        % Print the scores for this trial
        disp(['Trial ' num2str(t) ': ' num2str( Button_ScoresJD )]);
        
        % Store rewards for arms 1 and 2
        arm1_rewards = [arm1_rewards,  Button_ScoresJD (3)];
        arm2_rewards = [arm2_rewards,  Button_ScoresJD (4)];
    end

    % Calculate and display the correlation coefficient between arms 1 and 2
    correlation_coefficient = corrcoef(arm1_rewards, arm2_rewards);
    disp(['Correlation between Arm 1 and Arm 2: ', num2str(correlation_coefficient(1, 2))]);
end