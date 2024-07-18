% Function called by: Experiment.m
% Role of function is to update the values of each button after every trial
% Inputs: 
%   - N_Arms     (The number of arms/buttons)
%   - Change_Rng (Chance the points may change)
%   - Initialize (Whether or not we need to initialize our variables
% Outputs: 
%   - Button_Scores (The scores of all buttons in a list)

function [Button_Scores, change_log] = GetScores(N_Arms, Change_Rng, Initialize)
    persistent means std_devs prs_change_log

    if ~exist("Initialize", "var"); Initialize = false; end

    if Initialize || isempty(means) || isempty(std_devs) || isempty(prs_change_log)
        % Initialize means and standard deviations for the arms
        means = floor(20 + (80-20) * rand(1, N_Arms));   % Random means between 5 and 95 %std_devs = randi([1, 3], 1, N_Arms);
        std_devs = randi([1, 15], 1, N_Arms);% Random std devs chosen from 1 to 15
        prs_change_log = false(N_Arms,1); 
    else
        change_log_entry=false(N_Arms,1);
        % Update the means of the arms based on the given probability
        for arm = 1:N_Arms
            % 1 in 20 chance to change the mean of the arm
            if rand() < Change_Rng/100
                means(arm) = floor(20 + (80-20) * rand());
                change_log_entry(arm)=true;
                
            end
        end
        prs_change_log=[prs_change_log,change_log_entry];
    end
    % Calculate points as the combination of the mean plus standard deviation
    Button_Scores = means + std_devs .* (2 * randi([0, 1], 1, N_Arms) - 1);
    change_log= prs_change_log;
    % Button_Scores = max(min(Button_Scores, 100), 1);
end