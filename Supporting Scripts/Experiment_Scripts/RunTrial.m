% Function called by: Experiment.m
% Role of function is to run a trial of the experiment
% color_list.grey: 
%   - Parameters    (Things to be used for the experiment)
%   - Cpu           (The opponent that will be used for this trial)
%   - Duration      (How long the player has to react to the events on screen)
%   - Score_Row     (A list with the scores shuffled order for this Trial
%   - Instance_Idx  (Where in the trial we are)
%   - Layout        (Which layout to use)
%   - Trial_Total   (How much the player has scored so far in the trial)
% Return Values: 
%   - player_data   (Data on the player's performance)
%   - Trial_Total   (The updated total of all the trials)

function [player_data] = RunTrial(Parameters)
    load('colors.mat','color_list');

    %% PRE STAGE - Before the timer of the activity starts
    

    %% LOOP STAGE - The trial begins
    [elapsed_time, start] = deal(GetSecs());
    pause_offset = 0;
    
    % Flip a coin on who starts first
    if rand() < 0.5
        player_turn();
        cpu_turn();
    else
        cpu_turn();
        player_turn();
    end    
end

function player_turn()
    while elapsed_time-pause_offset-start <= Parameters.trial.duration_s
        pc_input = GetXBox();

        for button = Parameters.trial.button_names
            color = Parameters.trial.target_colors(idx,:);
            if pc_input.(Parameters.trial.button_names); color = color/0.8; end

            Screen('FillOval',Parameters.screen.window, color,...
                    Parameters.trial.target_rects(idx,:));

            DrawIcon()
        end
    end
end

function cpu_turn()
end