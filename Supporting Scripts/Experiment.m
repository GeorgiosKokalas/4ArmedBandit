% Function called by: main.m
% Role of function is to run the experiment, start to finish 
% Parameters: Parameters (Things to be used for the experiment)
% Return Values: None

function Experiment(Parameters)
    %% Do some precalculations
    % Create the list of all the cpus
    cpu_list = [CpuPlayer(2, "Indifferent", "Sam"), CpuPlayer(3, "Cooperative", "Tony"), CpuPlayer(5, "Competitive", "Kendal")];
    % cpu_list =  [CpuPlayer(5, "reductive")];
    Parameters.avatars.player = 1;

    % Find the number of blocks we will be having
    num_blocks = length(Parameters.disbtn.player) * length(Parameters.disbtn.cpu) * length(cpu_list);
    
    % Generate a list of all possible blocks
    [combos, combos_str] = deal([]);
    for cpu_idx = 1:width(cpu_list)
        for dp_idx = 1:length(Parameters.disbtn.player)
            dp_val = Parameters.disbtn.player(dp_idx);      % Obtain the value of the disabled button for the player
            for dc_idx = 1:length(Parameters.disbtn.cpu)
                dc_val = Parameters.disbtn.cpu(dc_idx);     % Obtain the value of the disabled button for the player
                cpu_num = sprintf('%d+%d', cpu_list(cpu_idx).Behavior_Mode, cpu_idx);  % Create a representation for the cpu
                combos = [combos;sprintf('%d%d%d',cpu_idx,dp_idx,dc_idx)];
                combos_str = [combos_str, string(sprintf("CPU-%s_%s-P_%s-C",cpu_num,dp_val,dc_val))];
            end
        end
    end

    % Generate tables that for our outputs
    [cpu_scores, pl_scores, pl_times] = deal(table('Size', [Parameters.trial.num, num_blocks],...
                                                   'VariableTypes', repmat("double", 1, num_blocks), ...
                                                   'VariableNames',combos_str));
    [cpu_choices, pl_choices] = deal(table('Size', [Parameters.trial.num, num_blocks],...
                                           'VariableTypes', repmat("string", 1, num_blocks), ...
                                           'VariableNames',combos_str));
    [pl_totals, cpu_totals] = deal(table('Size', [1, num_blocks],...
                                         'VariableTypes', repmat("double", 1, num_blocks), ...
                                         'VariableNames',combos_str));
    exp_events = {};
    
    % Randomize the blocks
    random_order = randperm(num_blocks);
    combos = combos(random_order, :);
    combos_str = combos_str(random_order);
    
    % Change to the directory that saves the data
    cd(Parameters.output_dir);
    
    %% Carry out the task
    % Carry out the Introduction to the task
    if Parameters.trial.show_intro
        Introduction(Parameters);
    end
    % return

    % Carry out each block
    for block_idx = 1:num_blocks
        % Handle Events
        blev_hold = parfeval(backgroundPool, @CreateEvent, 1, "blockStart", GetSecs(), block_idx, [], cpu_list(cpu_idx));
        
        % Create some variables needed for block storing
        table_name = combos_str(block_idx);                 % Which table entry we will be changing
        block_total = struct('player', 0, 'cpu', 0);        % The total scores during the block
        [button_scores, ~] = GetScoresUpdate(length(Parameters.target.button_names), ...  % The scores for each button
                        Parameters.target.score_change_rng, true);
        cpu_idx = str2double(combos(block_idx,1));          % the index of the cpu that we will be using
        disbtn = struct('player', Parameters.disbtn.player(str2double(combos(block_idx,2))), ...  % The disabled buttons for the player and cpu in the block
                        'cpu', Parameters.disbtn.cpu(str2double(combos(block_idx,3))));
        
        % Generate the message for the start of the block to the player
        blockStart(Parameters ,block_idx, num_blocks, cpu_list(cpu_idx).Name);  
        
        % Inform the cpu which of its choices it doesn't have access to
        cpu_list(cpu_idx).Choice_List = erase(cpu_list(cpu_idx).Choice_List, Parameters.disbtn.cpu(str2double(combos(block_idx,3))));
        
        block_events = fetchOutputs(blev_hold);
         for trial_idx = 1:Parameters.trial.num
            % Run a Trial and obtain the needed data
            [pl_data, cpu_data, block_total, trial_events, abort] = RunTrial(Parameters, disbtn, button_scores, ...
                                                                      cpu_list(cpu_idx), block_total, ...
                                                                      block_idx, trial_idx);
            
            % Append the events of the trial to the block information
            block_events = [block_events; trial_events];

            % Change the values of the scores based on the RNG
            [button_scores, ~] = GetScoresUpdate(length(Parameters.target.button_names), Parameters.target.score_change_rng);
            
            % Save the choices of the player on the tables
            pl_choices.(table_name)(trial_idx) = pl_data.choice;
            pl_scores.(table_name)(trial_idx)  = pl_data.score;
            pl_times.(table_name)(trial_idx)   = pl_data.time;
            
            % Save the choices of the cpu on the tables
            cpu_choices.(table_name)(trial_idx) = cpu_data.choice;
            cpu_scores.(table_name)(trial_idx)  = cpu_data.score;   
            
        end
        % Inform the player that the block has ended
        blockSwitch(Parameters,block_idx, num_blocks);

        blev_hold = parfeval(backgroundPool, @CreateEvent, 1, "blockEnd", GetSecs(), block_idx);
        block_events = [block_events; fetchOutputs(blev_hold)];
        
        Parameters.NewEvent(block_events);
        
        % Reset the Cpu player for future blocks
        cpu_list(cpu_idx).reset();
        
        % Save the totals of the cpu and the player
        pl_totals.(table_name) = block_total.player;
        cpu_totals.(table_name) = block_total.player;
        
        % Save the trial results
        block_filename    = sprintf('Block__%s.mat', table_name);
        block_pl_choices  = pl_choices.(table_name);
        block_pl_scores   = pl_scores.(table_name);
        block_pl_times    = pl_times.(table_name);
        block_cpu_scores  = cpu_scores.(table_name);
        block_cpu_choices = cpu_choices.(table_name);
        exp_events        = Parameters.exp_events;

        % Save the block results
        save(block_filename, "block_pl_choices", "block_pl_scores", "block_pl_times", ...
            "block_cpu_scores", "block_cpu_choices", "block_total", "block_events", "-mat");
    end
    
    % Save the experiment results
    save("All_Blocks.mat", "pl_choices", "pl_scores", "pl_times", "cpu_scores", ...
         "cpu_choices", "pl_totals", "cpu_totals", "exp_events", "-mat");

    % Cleanup the handles
    for idx = length(cpu_list):-1:1
        delete(cpu_list(idx));
    end
   
    DrawFormattedText(Parameters.screen.window, 'End', 'center', 'center', 252:255);

    % Update the Screen
    Screen('Flip',Parameters.screen.window);

    % Debrief(Parameters.screen, [sum(prison_score_table), sum(hunt_score_table)], ["Prisoner Task", "Hunting Trip"]);
end

%% HELPER FUNCTIONS
% blockStart - prints a message at the start of each block
% Arguments:
%   - Pars       (Reference to the parameters)
%   - Block_Idx  (The block number)
%   - Num_Blocks (The total number of blocks)
%   - Cpu_Name   (The name of the cpu player)
% Outputs: None
function blockStart(Pars, Block_Idx, Num_Blocks, Cpu_Name)
    % Generate the text to be printed
    text = sprintf('Starting Block %d out of %d.\n You will be playing with %s.\n\n', ...
                    Block_Idx, Num_Blocks, Cpu_Name);
    text = sprintf('%sPress any button to continue.', text);
    
    % Print the text and show it
    Screen('TextSize', Pars.screen.window, Pars.text.size.score_totals);
    DrawFormattedText(Pars.screen.window, text, 'center', 'center', 252:255);
    Screen('Flip', Pars.screen.window);
    
    % Wait for 2 seconds or until a button is pressed
    start = GetSecs();
    while GetSecs()-start < 2
        if KbCheck() || GetXBox().AnyButton; break; end
    end
    WaitSecs(0.3);
end

% blockSwitch - prints a message at the end of each block (except the final one)     
% Arguments:
%   - Pars       (The pointer to the experiment parameters)
%   - Block_Idx  (The block number)
%   - Num_Blocks (The total number of blocks)
% Outputs: None
function blockSwitch(Pars, Block_Idx, Num_Blocks)
    % If this is the final block, exit the function
    if Block_Idx == Num_Blocks; return; end
    
    % Generate the text that will be printed
    text = sprintf('Block %d Complete! %d more to go!\n\n\n', Block_Idx, Num_Blocks-Block_Idx);
    text = sprintf('%sPress any button to continue.', text);
    
    % Print the text and show it
    Screen('TextSize', Pars.screen.window, Pars.text.size.score_totals);
    DrawFormattedText(Pars.screen.window, text, 'center', 'center', 252:255);
    Screen('Flip', Pars.screen.window);
    
    % Wait for 2 seconds or until a button is pressed
    start = GetSecs();
    while GetSecs()-start < 2
        if KbCheck() || GetXBox().AnyButton; break; end
    end
    WaitSecs(0.3);
end