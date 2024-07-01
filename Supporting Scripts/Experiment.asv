% Function called by: main.m
% Role of function is to run the experiment, start to finish 
% Parameters: Parameters (Things to be used for the experiment)
% Return Values: None

function Experiment(Parameters)
    %% Do some precalculations
    cpu_list = [CpuPlayer(1), CpuPlayer(2)];
    
    % Find the number of blocks we will be having
    num_blocks = length(Parameters.disbtn.player) * length(Parameters.disbtn.cpu) * length(cpu_list);
    
    % Generate a list of all possible blocks
    [combos, combos_str] = deal([]);
    for cpu_idx = 1:width(cpu_list)
        for dp_idx = 1:length(Parameters.disbtn.player)
            dp_val = Parameters.disbtn.player(dp_idx);
            for dc_idx = 1:length(Parameters.disbtn.cpu)
                dc_val = Parameters.disbtn.cpu(dc_idx);
                combos = [combos;sprintf('%d%d%d',cpu_idx,dp_idx,dc_idx)];
                combos_str = [combos_str, string(sprintf("CPU-%d_%s-P_%s-C",cpu_idx,dp_val,dc_val))];
            end
        end
    end

    % Generate tables to hold the save variables
    [cpu_scores, pl_scores, pl_times] = deal(table('Size', [Parameters.trial.num, num_blocks],...
                                                   'VariableTypes', repmat("double", 1, num_blocks), ...
                                                   'VariableNames',combos_str));
    [cpu_choices, pl_choices] = deal(table('Size', [Parameters.trial.num, num_blocks],...
                                           'VariableTypes', repmat("string", 1, num_blocks), ...
                                           'VariableNames',combos_str));
    [pl_totals, cpu_totals] = deal(table('Size', [1, num_blocks],...
                                         'VariableTypes', repmat("double", 1, num_blocks), ...
                                         'VariableNames',combos_str));

    % Randomize the blocks
    random_order = randperm(num_blocks);
    combos = combos(random_order, :);
    combos_str = combos_str(random_order);
    
    % Change to the directory that saves the data
    cd(Parameters.output_dir);
    
    %% Carry out the task
    % Carry out the Introduction to the task
    if Parameters.trial.show_intro
        Introduction(Parameters.screen, Parameters.text, Parameters.target);
    end

    % Carry out each block
    for block_idx = 1:num_blocks
        % Create some variables needed for block storing
        table_name = combos_str(block_idx);
        block_total = struct('player', 0, 'cpu', 0);
        button_scores = GetScores(length(Parameters.target.button_names), Parameters.target.score_change_rng, true);
        cpu_idx = str2double(combos(block_idx,1));
        disbtn = struct('player', Parameters.disbtn.player(str2double(combos(block_idx,2))), ...
                        'cpu', Parameters.disbtn.cpu(str2double(combos(block_idx,3))));
        for trial_idx = 1:Parameters.trial.num
            [pl_data, cpu_data, block_total] = RunTrial(Parameters, disbtn, button_scores, cpu_list(cpu_idx), block_total);
            button_scores = GetScores(length(Parameters.target.button_names), Parameters.target.score_change_rng);

            pl_choices.(table_name)(trial_idx) = pl_data.choice;
            pl_scores.(table_name)(trial_idx)  = pl_data.score;
            pl_times.(table_name)(trial_idx)   = pl_data.time;

            cpu_choices.(table_name)(trial_idx) = cpu_data.choice;
            cpu_scores.(table_name)(trial_idx)  = cpu_data.score;   
            
        end
        BlockSwitch(Parameters.screen.window,block_idx, num_blocks);

        pl_totals.(table_name) = block_total.player;
        cpu_totals.(table_name) = block_total.player;
        
        % Save the trial results
        block_filename    = sprintf('Block__%s.mat', table_name);
        block_pl_choices  = pl_choices.(table_name);
        block_pl_scores   = pl_scores.(table_name);
        block_pl_times    = pl_times.(table_name);
        block_cpu_scores  = cpu_scores.(table_name);
        block_cpu_choices = cpu_choices.(table_name);

        save(block_filename, "block_pl_choices", "block_pl_scores", "block_pl_times", ...
            "block_cpu_scores", "block_cpu_choices", "block_total", "-mat");
    end
    
    save("All_Blocks.mat", "pl_choices", "pl_scores", "pl_times", "cpu_scores", ...
         "cpu_choices", "pl_totals", "cpu_totals", "-mat");

    % Cleanup
    for idx = length(cpu_list):-1:1
        delete(cpu_list(idx));
    end
    
    DrawFormattedText(Parameters.screen.window, 'End', 'center', 'center');

    % Update the Screen
    Screen('Flip',Parameters.screen.window);

    % Debrief(Parameters.screen, [sum(prison_score_table), sum(hunt_score_table)], ["Prisoner Task", "Hunting Trip"]);

end