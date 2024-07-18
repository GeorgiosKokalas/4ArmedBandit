% Function called by: main.m
% Role of function is to run the experiment, start to finish 
% Parameters: Parameters (Things to be used for the experiment)
% Return Values: None

function Experiment(Parameters)
    %% Do some precalculations
    % Create the list of all the cpus
    %might need to change to 2,4,5
    cpu_list = [CpuPlayer(2, "Indifferent", "Sam"), CpuPlayer(4, "Cooperative", "Tony"), CpuPlayer(5, "Competitive", "Kendal"),...
                CpuPlayer(2, "Indifferent", "Sam"), CpuPlayer(4, "Cooperative", "Tony"), CpuPlayer(5, "Competitive", "Kendal")];
    % cpu_list =  [CpuPlayer(5, "Competitive", "Kendal")];

    Parameters.avatars.player = 1;
    abort = false;

    % Find the number of blocks we will be having
    num_blocks = length(Parameters.disbtn.player) * length(Parameters.disbtn.cpu) * length(cpu_list);
    
    % Generate a list of all possible blocks
    [combos, combos_str] = deal([]);
    for cpu_idx = 1:width(cpu_list)
        for dp_idx = 1:length(Parameters.disbtn.player)
            dp_val = Parameters.disbtn.player(dp_idx);      % Obtain the value of the disabled button for the player
            for dc_idx = 1:length(Parameters.disbtn.cpu)
                dc_val = Parameters.disbtn.cpu(dc_idx);     % Obtain the value of the disabled button for the player
                cpu_num = sprintf('%d-%d', cpu_list(cpu_idx).Behavior_Mode, cpu_idx);  % Create a representation for the cpu
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
    all_button_scores = struct;
    [all_score_means, all_distances, score_change_logs] = deal(struct);
    exp_events = {};
    
    % Randomize the blocks
    random_order = randperm(num_blocks);
    combos = combos(random_order, :);
    combos_str = combos_str(random_order);
    combo_logs = {};
    for idx = 1:height(combos)
        combo_logs = [combo_logs; {combos(idx), combos_str(idx)}];
    end
    
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
        if abort; break; end

        % Handle Events
        block_events = CreateEvent("blockStart", block_idx, [], cpu_list(cpu_idx));
        
        % Create some variables needed for block storing
        table_name = combos_str(block_idx);                 % Which table entry we will be changing
        block_str_name = ['b', combos(block_idx,:)];        % How to call struct sections for this block
        block_total = struct('player', 0, 'cpu', 0);        % The total scores during the block
        cpu_idx = str2double(combos(block_idx,1));          % the index of the cpu that we will be using
        disbtn = struct('player', Parameters.disbtn.player(str2double(combos(block_idx,2))), ...  % The disabled buttons for the player and cpu in the block
                        'cpu', Parameters.disbtn.cpu(str2double(combos(block_idx,3))));
        [button_scores, block_change_logs, score_means, mhb_dist] = GetScores(Parameters.target.button_names, ...  % The scores for each button
                                                                      Parameters.target.score_change_rng,...
                                                                      disbtn.player, true);
        all_button_scores.(block_str_name) = button_scores;
        all_score_means.(block_str_name) = score_means;
        all_distances.(block_str_name) = mhb_dist;
        
        % Generate the message for the start of the block to the player
        blockStart(Parameters ,block_idx, num_blocks, cpu_list(cpu_idx).Name);  
        
        % Inform the cpu which of its choices it doesn't have access to
        cpu_list(cpu_idx).Choice_List = erase(cpu_list(cpu_idx).Choice_List, Parameters.disbtn.cpu(str2double(combos(block_idx,3))));

         for trial_idx = 1:Parameters.trial.num
             % Run a Trial and obtain the needed data
             if abort; break; end
             [pl_data, cpu_data, block_total, trial_events, extras] = RunTrial(Parameters, disbtn, button_scores, ...
                                                                      cpu_list(cpu_idx), block_total, ...
                                                                      block_idx, trial_idx);
             abort = extras.abort;
             button_scores = extras.button_scores;

              all_button_scores.(block_str_name) = [all_button_scores.(block_str_name) ; extras.archived_bs];
             all_score_means.(block_str_name)   = [all_score_means.(block_str_name)   ; extras.archived_sm];
             all_distances.(block_str_name)     = [all_distances.(block_str_name)     ; extras.archived_mhb];
             
             if ~isnan(extras.block_cl); block_change_logs = extras.block_cl; end

             % Append the events of the trial to the block information
             block_events = [block_events; trial_events];

             % Save the choices of the player on the tables
             pl_choices.(table_name)(trial_idx) = pl_data.choice;
             pl_scores.(table_name)(trial_idx)  = pl_data.score;
             pl_times.(table_name)(trial_idx)   = pl_data.time;

             % Save the choices of the cpu on the tables
             cpu_choices.(table_name)(trial_idx) = cpu_data.choice;
             cpu_scores.(table_name)(trial_idx)  = cpu_data.score;
        end
        % Inform the player that the block has ended
        blockSwitch(Parameters,block_idx, num_blocks, cpu_list(cpu_idx), block_total);

        block_events = [block_events; CreateEvent("blockEnd", block_idx)];
        
        Parameters.NewEvent(block_events);
        
        % Reset the Cpu player for future blocks
        cpu_list(cpu_idx).reset();
        
        % Save the totals of the cpu and the player
        pl_totals.(table_name) = block_total.player;
        cpu_totals.(table_name) = block_total.player;
        
        % Save the trial results
        block_filename      = sprintf('Block_%s.mat', table_name);
        block_pl_choices    = pl_choices.(table_name);
        block_pl_scores     = pl_scores.(table_name);
        block_pl_times      = pl_times.(table_name);
        block_cpu_scores    = cpu_scores.(table_name);
        block_cpu_choices   = cpu_choices.(table_name);
        block_button_scores = all_button_scores.(block_str_name);
        block_score_means   = all_score_means.(block_str_name);
        exp_events          = Parameters.exp_events;
        block_mhb_distances = all_distances.(block_str_name);

        % Save the block results
        save(block_filename, "block_pl_choices", "block_pl_scores", "block_pl_times", "block_change_logs",...
            "block_cpu_scores", "block_cpu_choices", "block_total", "block_events", "block_score_means",...
            "block_button_scores", "block_mhb_distances", "-mat");

        score_change_logs.(block_str_name) = block_change_logs;
    end
    
    % Save the experiment results
    save("All_Blocks.mat", "pl_choices", "pl_scores", "pl_times", "cpu_scores", "score_change_logs", ...
         "cpu_choices", "pl_totals", "cpu_totals", "exp_events", "combo_logs", "all_score_means",...
         "all_button_scores", "all_distances", "-mat");

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
%   - Cpu        (A handle to the CPU)
%   - Totals     (The total scores of the experiment)
% Outputs: None
function blockSwitch(Pars, Block_Idx, Num_Blocks, Cpu, Totals)
    total_score = 0;
    switch lower(string(Cpu.Score_Mode))
        case "competitive"
            total_score = Totals.player - Totals.cpu;
        case "cooperative"
            total_score = Totals.player + Totals.cpu;
        otherwise
            total_score = Totals.player;
    end

    text = sprintf('Block Total Score: %d!\n', total_score);

    % If this is the final block, exit the function
    if Block_Idx ~= Num_Blocks
        text = sprintf('%s\nBlock %d Complete! %d more to go!', text, Block_Idx, Num_Blocks-Block_Idx);
        text = sprintf('%s\nPress any button to continue.', text);
    end
    
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