% Function called by: Experiment.m
% Role of function is to update the values of each button after every trial
% Inputs: 
%   - N_Arms     (The number of arms/buttons)
%   - Change_Rng (Chance the points may change)
%   - Initialize (Whether or not we need to initialize our variables
% Outputs: 
%   - Button_Scores (The scores of all buttons in a list)

function Button_Scores = GetScores(N_Arms, Change_Rng, Initialize)
    persistent means std_devs

    if ~exist("Initialize", "var"); Initialize = false; end

    if Initialize || isempty(means) || isempty(std_devs)
        % Initialize means and standard deviations for the arms
        means = floor(5 + (95-5) * rand(1, N_Arms));   % Random means between 5 and 95
        std_devs = randi([1, 3], 1, N_Arms);    % Random std devs chosen from 1, 2, or 3
    else
        % Update the means of the arms based on the given probability
        for arm = 1:N_Arms
            % 1 in 20 chance to change the mean of the arm
            if rand() < Change_Rng/100
                means(arm) = floor(5 + (95-5) * rand());
            end
        end
        
    end
    % Calculate points as the combination of the mean plus standard deviation
    Button_Scores = means + std_devs;
end