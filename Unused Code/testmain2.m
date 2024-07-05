% Initialize parameters
n_trials = 50;
change_prob = 1/20;

% Initialize CpuPlayer
cpu = CpuPlayer(1);  % Behavior mode 1 (epsilon-greedy)

% Initialize the scores for the arms
N_Arms =4;
Initialize = true;

% Function called by: Experiment.m
% Role of function is to update the values of each button after every trial
% Inputs: 
%   - N_Arms     (The number of arms/buttons)
%   - Change_Rng (Chance the points may change)
%   - Initialize (Whether or not we need to initialize our variables
% Outputs: 
%   - Button_Scores (The scores of all buttons in a list)

% Run trials
for trial = 1:n_trials
    % Get the points for the current state of the arms
    points = GetScores(N_Arms, change_prob, Initialize);
    Initialize = false;  % Set Initialize to false after the first call
    disp(['Points for this round: ', num2str(points)])
    % CPU makes a choice based on the current behavior mode
    cpu.changeBehavior();
    
    % Simulate getting a reward for the chosen arm
    choice = cpu.getResponse();
    choice_index = find(cpu.Choice_List == choice);
    reward = points(choice_index+1);
    
    % Update CPU's knowledge with the reward
    cpu.updateRewards(choice, reward);
    
    % Output the CPU's choice and the reward received
    disp(['Trial ', num2str(trial), ': CPU chose ', choice, ' and received reward ', num2str(reward)]);
    
    % Reset choice (optional, based on your requirements)
    %cpu.reset();
end
