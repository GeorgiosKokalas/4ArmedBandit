% Function called by: Experiment.m
% Role of function is to run a trial of the experiment
% color_list.grey: 
%   - Parameters    (Things to be used for the experiment)
%   - Disbtn        (The buttons disabled for the player and cpu)
%   - Button_Scores (The score values of  each button)
%   - Cpu           (A pointer to the cpu handle)
%   - Totals        (The total scores of the cpu and player)
%   - Block_Idx     (Which block we are on)
%   - Trial_Idx     (Which trial we are on)
% Return Values: 
%   - player_data   (Data on the player's performance)
%   - cpu_data      (Data on the cpu's performance)
%   - Totals        (The updated Totals initially provided)
%   - trial_events  (The events that occured during this trial and their time 

function [player_data, cpu_data, Totals, trial_events, abort] = RunTrial(Parameters, Disbtn, Button_Scores, Cpu, Totals, Block_Idx, Trial_Idx)
    %% PRE STAGE - Before the timer of the activity starts
    % Initialize some of the variables we need for storing
    pd_s = Parameters.trial.photodiode_dur_s;
    abort = false;
    trial_events = {sprintf('Block %d Trial %d - START', Block_Idx, Trial_Idx), GetSecs()};


    %% PRESENTATION STAGE - The trial begins    
    % Show a rotating image of the 
    % rotation_start = GetSecs();
    rotation_result = rand() * 360;
    % current_rotation = 0;
    % while GetSecs() - rotation_start < 0.5 + rotation_result/720
    %     img_start = GetSecs();
    %     Screen('TextSize', Parameters.screen.window, Parameters.text.size.scores);
    %     DrawFormattedText2('Who goes first?', 'win', Parameters.screen.window, 'sx', 'center',...
    %                        'sy', 'top', 'xalign', 'center', 'baseColor', 252:255);
    % 
    %     avatar_size = min(Parameters.screen.window_width/2, Parameters.screen.window_height/2);
    %     player_rect = [0,  Parameters.screen.center(2) - avatar_size/2, ...
    %                    Parameters.screen.center(1), Parameters.screen.center(2) + avatar_size/2];
    %     cpu_rect = [Parameters.screen.center(1), Parameters.screen.center(2) - avatar_size/2, ...
    %                 Parameters.screen.window_width,  Parameters.screen.center(2) + avatar_size/2];
    % 
    %     DrawIcon(Parameters.screen.window, ['PlAv', num2str(Parameters.avatars.player), '.png'], player_rect);
    %     DrawIcon(Parameters.screen.window, ['CpuAv', num2str(Cpu.Behavior_Mode), '.png'], cpu_rect);
    % 
    %     arrow_rect = [Parameters.screen.center(1) - 250, Parameters.screen.center(2) - 250,...
    %                   Parameters.screen.center(1) + 250, Parameters.screen.center(2) + 250];
    % 
    %     DrawIcon(Parameters.screen.window, 'Arrow.png', arrow_rect, current_rotation);
    %     current_rotation = current_rotation + 36;
    % 
    %     Screen('Flip', Parameters.screen.window);
    %     WaitSecs(0.05 - (GetSecs() - img_start));
    % end
    % WaitSecs(1);


    % Flip a coin on who starts first
    disp("NEW TRIAL")
    if rotation_result > 180
        [player_data, Totals, pl_events] = playerTurn(Parameters.screen, Parameters.target,...
                                                       Disbtn.player, Button_Scores, Totals, ...
                                                       Parameters.text.size, Parameters.avatars, Cpu,...
                                                       Block_Idx, Trial_Idx, pd_s);
        [cpu_data, Totals, cpu_events] = cpuTurn(Parameters.screen, Parameters.target, Parameters.trial,...
                                                   Disbtn.cpu, Button_Scores, Cpu, Totals,...
                                                   Parameters.text.size, Parameters.avatars,...
                                                   Block_Idx, Trial_Idx, pd_s);
        trial_events = [trial_events; pl_events; cpu_events];
    else
        [cpu_data, Totals, cpu_events] = cpuTurn(Parameters.screen, Parameters.target, Parameters.trial,...
                                                   Disbtn.cpu, Button_Scores, Cpu, Totals,...
                                                   Parameters.text.size, Parameters.avatars,...
                                                   Block_Idx, Trial_Idx, pd_s);
        [player_data, Totals, pl_events] = playerTurn(Parameters.screen, Parameters.target,...
                                                       Disbtn.player, Button_Scores, Totals, ...
                                                       Parameters.text.size, Parameters.avatars, Cpu,...
                                                       Block_Idx, Trial_Idx,pd_s);
        trial_events = [trial_events; cpu_events; pl_events];
    end
end


%% HELPER FUNCTIONS
% playerTurn - Function for the turn of the player
% Arguments:
%   - Screen_Pars   (The Parameters for the screen)
%   - Targ_Pars     (The Parameters for the targets)
%   - Disbtn        (The buttons disabled for the player and cpu)
%   - Button_Scores (The score values of  each button)
%   - Totals        (The total scores of the cpu and player)
%   - Text_Size     (The Parameters for the text size)
%   - Avatars       (The Parameters for the avatars)
%   - Cpu           (A pointer to the cpu handle)
%   - Block_Idx     (Which block we are on)
%   - Trial_Idx     (Which trial we are on)
%   - PD_S          (The duration of the photodiode in seconds)
% Outputs: 
%   - pl_data       (Data on the player's performance)
%   - Totals        (The updated Totals initially provided)
%   - events        (A list of the events that happened during the player's turn)   
function [pl_data, Totals, events] = playerTurn(Screen_Pars, Targ_Pars, Disbtn, Button_Scores, Totals, Text_Size, Avatars, Cpu, Block_Idx, Trial_Idx, PD_S)
    %% PRE CALCULATIONS FOR THE PLAYER TURN
    load("colors.mat", "color_list");
    disp("Player turn ")
    choice_idx = -1;

    % Variables for loop control
    break_loop = false;
    [pause_offset, score] = deal(0);
    start = GetSecs();
    elapsed_time = GetSecs() - start;
    
    % Note the start of the turn as an event
    events = {sprintf('Block %d Trial %d - Player Turn Start', Block_Idx, Trial_Idx), GetSecs()};
    
    %% LOOP PHASE - player will be making their choice
    while ~break_loop
        % Get the player's input
        pc_input = GetXBox();

        % Draw the photodiode if this is the best time
        if elapsed_time < PD_S; DrawPhotoDiode(Screen_Pars); end
        
        % Draw the Avatars and any extra stuff
        drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu, Totals, Trial_Idx, false);
        
        % Draw each button
        for button_idx = 1:length(Targ_Pars.button_names)
            % Get the color of the button
            color = Targ_Pars.colors(button_idx,:);

            % In case we have selected a button to press, do these steps
            if pc_input.(Targ_Pars.button_names(button_idx)) && ~break_loop
                color = color/0.8; 

                % If the button is eligible, act accordingly     
                if ~strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                    DrawPhotoDiode(Screen_Pars); % Draw the photodiode for the event
                    % Note the event
                    events = [events;{sprintf('Block %d Trial %d - Player Turn Choice', Block_Idx, Trial_Idx), GetSecs()}];
                    
                    % Store the choice, the score and update the totals.
                    choice = Targ_Pars.button_names(button_idx);
                    choice_idx = button_idx;
                    score = Button_Scores(button_idx);
                    Totals.player = Totals.player + score;
                    
                    % Inform the script that the loop should be broken
                    break_loop = true;
                end
            end
            
            % Create the circle to be drawn for the target. Draw a ring if the player has pressed the target     
            Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));
            if pc_input.(Targ_Pars.button_names(button_idx)) && break_loop 
                Screen('FrameOval',Screen_Pars.window, repmat(255,1,4), Targ_Pars.ring_rects(button_idx,:), 10);
            end
            
            % Draw the Letters of the buttons
            DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                Targ_Pars.rects(button_idx,:));
            
            % If the button is disabled, draw a semi-transparent circle over it to gray it out.     
            if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                Screen('FillOval',Screen_Pars.window, [20, 20, 20, 230], Targ_Pars.ring_rects(button_idx,:));
            end
        end
        % Output the imagery
        Screen('Flip', Screen_Pars.window);
        
        % Update the elapsed time and exit the loop if needed
        elapsed_time = GetSecs()-pause_offset-start;
        if break_loop; break; end
    end
    WaitSecs(PD_S); % Wait for the photodiode to shine
    
    %% SHOW THE SCORES THE PLAYER HAS GOTTEN
    % Draw the Avatars and any extra stuff
    drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu, Totals, Trial_Idx, false);
    
    % Draw each button
    for button_idx = 1:length(Targ_Pars.button_names)
        % Get the color and highlight it if selected
        color = Targ_Pars.colors(button_idx,:);
        if button_idx == choice_idx; color = color/0.8; end

        % Create the circle to be drawn for the target
        Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));

        % If the score is to be shown, draw the score and the ring. Otherwise draw the button letter
        if button_idx == choice_idx
            Screen('TextSize', Screen_Pars.window, Text_Size.button_score);
            DrawFormattedText2(num2str(score), 'win', Screen_Pars.window, 'sx', Targ_Pars.coords(button_idx, 1), ...
                'sy', Targ_Pars.coords(button_idx, 2), 'xalign', 'center', 'yalign','center',...
                'baseColor', color_list.white);
            Screen('FrameOval',Screen_Pars.window, repmat(255,1,4), Targ_Pars.ring_rects(button_idx,:), 10);
        else
            DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                Targ_Pars.rects(button_idx,:));
        end

        % If the button is disabled, draw a semi-transparent circle over it to gray it out.
        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval',Screen_Pars.window, [20, 20, 20, 230], Targ_Pars.ring_rects(button_idx,:));
        end
    end
    Screen('Flip', Screen_Pars.window);
    
    % Get the data for the player to be returned
    pl_data = struct('time',elapsed_time, 'score', score, 'choice', choice);
    WaitSecs(1);
end

% cpuTurn - Function for the turn of the cpu
% Arguments:
%   - Screen_Pars   (The Parameters for the screen)
%   - Targ_Pars     (The Parameters for the targets)
%   - Trial_Pars    (The Parameters for the trials)
%   - Disbtn        (The buttons disabled for the player and cpu)
%   - Button_Scores (The score values of  each button)
%   - Cpu           (A pointer to the cpu handle)
%   - Totals        (The total scores of the cpu and player)
%   - Text_Size     (The Parameters for the text size)
%   - Avatars       (The Parameters for the avatars)
%   - Block_Idx     (Which block we are on)
%   - Trial_Idx     (Which trial we are on)
%   - PD_S          (The duration of the photodiode in seconds)
% Outputs: 
%   - cpu_data      (Data on the cpu's performance)
%   - Totals        (The updated Totals initially provided)
%   - events        (A list of the events that happened during the player's turn)   
function [cpu_data, Totals, events] = cpuTurn(Screen_Pars, Targ_Pars, Trial_Pars, Disbtn, Button_Scores, Cpu, Totals, Text_Size, Avatars, Block_Idx, Trial_Idx, PD_S)
    %% PRE-CALCULATIONS FOR CPU TURN
    % Determine how long the cpu will wait to emulate decision making
    cpu_time = rand()* Trial_Pars.cpu_wait_dur + Trial_Pars.cpu_wait_s(1);
    
    % Note the event of the cpu beginning its turn
    disp("Cpu - prechoice")
    events = {sprintf('Block %d Trial %d - CPU Turn Start', Block_Idx, Trial_Idx), GetSecs()};
    
    %% CPU PRECHOICE ILLUSTRATIONS
    % PHOTODIODE MODE
    pd_mode_start = GetSecs();

    % Draw the background and the board
    drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu, Totals, Trial_Idx, true); 
    cpuDrawPart1(Screen_Pars, Targ_Pars, Disbtn, true);
    
    % Wait until the photodiode needs to be drawn no longer    
    WaitSecs(max(0, PD_S - (GetSecs() - pd_mode_start)));
    
    % NON PHOTODIODE MODE
    npd_mode_start = GetSecs();

    % Draw the background and the board
    drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu, Totals, Trial_Idx, true);
    cpuDrawPart1(Screen_Pars, Targ_Pars, Disbtn, false);
    
    % Calculate the cpu's choice and its outcomes
    cpu_choice = Cpu.getResponse(Button_Scores);
    score_idx = Targ_Pars.button_names == cpu_choice;
    cpu_score = Button_Scores(score_idx);
    Totals.cpu = Totals.cpu + cpu_score;
    Cpu.changeBehavior(cpu_score);
    
    % Wait until the cpu's wait time has finished
    WaitSecs(max(0, cpu_time - PD_S - (GetSecs() - npd_mode_start)));
    
    %% CPU POSTCHOICE ILLUSTRATIONS
    % Make a note of the cpu's choice as an event
    disp("Cpu - postchoice")
    events = [events;{sprintf('Block %d Trial %d - CPU Turn Choice', Block_Idx, Trial_Idx), GetSecs()};];

    % PHOTODIODE MODE
    pd_mode_start = GetSecs();

    % Draw the Avatars and board
    drawAvatars(Screen_Pars, Avatars, Text_Size,Cpu, Totals, Trial_Idx, true);
    cpuDrawPart2(Screen_Pars, Targ_Pars, Disbtn, cpu_choice, cpu_score, Text_Size, true); % photodiode event
    
    % Wait until the photodiode needs to be drawn no longer    
    WaitSecs(max(0, PD_S - (GetSecs() - pd_mode_start)));
    
    % NON PHOTODIODE MODE
    % Draw the Avatars and board
    drawAvatars(Screen_Pars, Avatars, Text_Size,Cpu, Totals, Trial_Idx, true);
    cpuDrawPart2(Screen_Pars, Targ_Pars, Disbtn, cpu_choice, cpu_score, Text_Size, false);
    WaitSecs(1);
    
    % save the data of the turn
    cpu_data = struct('score', cpu_score, 'choice', cpu_choice);
end

% cpuDrawPart1 - Drawing before the cpu makes a choice
% Arguments:
%   - Screen_Pars       (The Parameters for the screen)
%   - Targ_Pars         (The Parameters for the targets)
%   - Disbtn            (The buttons disabled for the player and cpu)
%   - Show_PhotoDiode   (If the photodiode should be shown)
% Outputs: None
function cpuDrawPart1(Screen_Pars, Targ_Pars, Disbtn, Show_PhotoDiode)
    % Draw each button
    for button_idx = 1:length(Targ_Pars.button_names)
        % Get the color of the button
        color = Targ_Pars.colors(button_idx,:);
        
        % Draw the button and its letter
        Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));
        DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                 Targ_Pars.rects(button_idx,:));
        
        % Obscure the disabled button
        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval',Screen_Pars.window, [20, 20, 20, 230], Targ_Pars.ring_rects(button_idx,:));
        end
    end
    
    % If the photodiode is to be shown, do it
    if Show_PhotoDiode; DrawPhotoDiode(Screen_Pars); end
    
    % Put everything on screen
    Screen('Flip', Screen_Pars.window);
end

% cpuDrawPart2 - Drawing after the cpu makes a choice
% Arguments:
%   - Screen_Pars       (The Parameters for the screen)
%   - Targ_Pars         (The Parameters for the targets)
%   - Disbtn            (The buttons disabled for the player and cpu)
%   - Cpu_Choice        (The choice (letter) of the cpu)
%   - Cpu_Score         (The score the cpu got from its choice
%   - Text_Size         (The Parameters for the size of the text)
%   - Show_PhotoDiode   (If the photodiode should be shown)
% Outputs: None
function cpuDrawPart2(Screen_Pars, Targ_Pars, Disbtn, Cpu_Choice, Cpu_Score, Text_Size, Show_PhotoDiode)
    % Draw each button
    for button_idx = 1:length(Targ_Pars.button_names)
        % Get the color and initialize a decision
        show_score = false;
        color = Targ_Pars.colors(button_idx,:);
        
        % If the cpu chose this button update the previous values
        if strcmpi(Targ_Pars.button_names(button_idx), Cpu_Choice)
            if ~strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                color = color / 0.8;
                show_score = true;
            end
        end
        
        % Draw the buttons and either its letter or the score with a ring (if this is the chosen button) 
        Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));
        if show_score
            Screen('FrameOval',Screen_Pars.window, repmat(255,1,4), Targ_Pars.ring_rects(button_idx,:), 10);
        end
        if show_score && ~Show_PhotoDiode
            Screen('TextSize', Screen_Pars.window, Text_Size.button_score);
            DrawFormattedText2(num2str(Cpu_Score), 'win', Screen_Pars.window, 'sx', Targ_Pars.coords(button_idx, 1), ...
                               'sy', Targ_Pars.coords(button_idx, 2), 'xalign', 'center', 'yalign','center',...
                               'baseColor', [0,0,0,255]);
        else
            DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                     Targ_Pars.rects(button_idx,:));
        end
        
        % If this is the disabled button, obscure it
        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval', Screen_Pars.window, [20, 20, 20, 230], Targ_Pars.ring_rects(button_idx,:));
        end
    end

    % If the photodiode is to be drawn, do it
    if Show_PhotoDiode; DrawPhotoDiode(Screen_Pars); end
    
    % Present everything
    Screen('Flip', Screen_Pars.window);
end

% drawAvatars - Draws the avatars and a lot of background stuff (outdated name)    
% Arguments:
%   - Screen_Pars   (The Parameters for the screen)
%   - Avatars       (The Parameters for the avatars)
%   - Text_Size     (The Parameters for the size of the text)
%   - Totals        (The total scores of the cpu and player)
%   - Trial_Idx     (Which trial we are on)
%   - Hide_Player   (If the player should be hiden. True in Cpu's turn. False in  player's turn.)     
% Outputs: None
function drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu, Totals, Trial_Idx, Hide_Player)
    white = repmat(255, 1, 4);

    % Draw the Score Mode
    score_mode_rect = [0, 0, Screen_Pars.window_width, Text_Size.score_mode + 10];
    score_mode_color = [200, 200, 0, 255];
    switch lower(Cpu.Score_Mode)
        case 'cooperative'; score_mode_color = [0, 0, 255, 255];
        case 'competitive'; score_mode_color = [255, 0, 0, 255];
    end
    Screen('TextSize', Screen_Pars.window, Text_Size.score_mode);
    Screen('FillRect', Screen_Pars.window, score_mode_color, score_mode_rect);
    DrawFormattedText2(char(Cpu.Score_Mode), 'win', Screen_Pars.window, 'sx', 'center', 'sy', 5, ...
                       'xalign', 'center', 'baseColor', white);

    % Draw the Trial Number
    Screen('TextSize', Screen_Pars.window, Text_Size.turn_order);
    DrawFormattedText2(sprintf('Trial %d :', Trial_Idx), 'win', Screen_Pars.window, 'sx', 'center', ...
                       'sy', Text_Size.score_mode + 15, 'xalign', 'right', 'baseColor', white); 
    
    % Draw out the avatars
    DrawIcon(Screen_Pars.window, ['PlAv', num2str(Avatars.player), '.png'], Avatars.player_rect);
    DrawIcon(Screen_Pars.window, ['CpuAv', num2str(Cpu.Behavior_Mode), '.png'], Avatars.cpu_rect);

    % See which entity to hide
    if Hide_Player
        Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], Avatars.player_gray_rect);
        Screen('FrameRect', Screen_Pars.window, [0, 255, 0, 255], Avatars.cpu_rect, 5);
        DrawFormattedText2(['  ', Cpu.Name], 'win', Screen_Pars.window, 'sx', 'center', 'sy', Text_Size.score_mode + 15 , ...
                           'xalign', 'left', 'baseColor', [204, 50, 50, 255]); 
    else
        Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], Avatars.cpu_gray_rect);
        Screen('FrameRect', Screen_Pars.window, [0, 255, 0, 255], Avatars.player_rect, 5);
        DrawFormattedText2('  You', 'win', Screen_Pars.window, 'sx', 'center', 'sy', Text_Size.score_mode + 15,  ...
                           'xalign', 'left', 'baseColor', [45, 201, 55, 255]); 
    end
    
    % Draw the textboxes for the player and the CPU
    Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], Avatars.player_textbox_rect);
    Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], Avatars.cpu_textbox_rect);

    % Display the titles for the player and the CPU
    title_sy = (Text_Size.score_mode + 10) + (Avatars.avatar_height-7);
    Screen('TextSize', Screen_Pars.window, Text_Size.title);
    DrawFormattedText2('You', 'win', Screen_Pars.window, 'sx', Avatars.avatar_width/2, 'sy', title_sy,...
                       'xalign', 'center', 'yalign', 'bottom', 'baseColor', white);
    DrawFormattedText2(Cpu.Name, 'win', Screen_Pars.window, 'sx', Screen_Pars.window_width-Avatars.avatar_width/2, ...
                       'sy', title_sy, 'xalign', 'center', 'yalign', 'bottom', 'baseColor', white);
    
    % Display the scores, based on the score mode of the cpu
    Screen('TextSize', Screen_Pars.window, Text_Size.scores);
    % player
    DrawFormattedText2('Score', 'win', Screen_Pars.window, 'sx', Avatars.avatar_width + 15, ...
                        'sy', Text_Size.score_mode + 10 + Text_Size.scores, 'yalign', 'bottom', ...
                        'baseColor', white);
    DrawFormattedText2(num2str(Totals.player), 'win', Screen_Pars.window, 'sx', Avatars.avatar_width + 15, ...
                       'sy', Text_Size.score_mode + 10 + Text_Size.scores*2, 'yalign', 'bottom', 'baseColor', white);
    % CPU
    DrawFormattedText2('Score', 'win', Screen_Pars.window, 'sx', Avatars.left_avatar_xstart - 15, ...
                       'sy', Text_Size.score_mode + 10 + Text_Size.scores, 'xalign', 'right', ...
                       'yalign', 'bottom', 'baseColor', white);
    DrawFormattedText2(num2str(Totals.cpu), 'win', Screen_Pars.window, 'sx', Avatars.left_avatar_xstart - 15,...
                       'sy', Text_Size.score_mode + 10 + Text_Size.scores*2, 'xalign', 'right', ...
                       'yalign', 'bottom', 'baseColor', white);

    % Make displays based on the CPU score mode
    switch lower(Cpu.Score_Mode)
        case 'cooperative'
            Screen('TextSize', Screen_Pars.window, Text_Size.score_totals);
            score_msg = sprintf(' %d', Totals.player + Totals.cpu);
            DrawFormattedText2('Total ', 'win', Screen_Pars.window, 'sx', 'center', ...
                               'sy', Screen_Pars.window_height - 5, 'xalign', 'right', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', white);
            DrawFormattedText2(score_msg, 'win', Screen_Pars.window, 'sx', 'center', ...
                               'sy', Screen_Pars.window_height - 5, 'xalign', 'left', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', [0, 0, 255, 255]);
        case 'competitive'
            score_color = [50,50,255,255];
            score_msg = sprintf(' %d', Totals.player - Totals.cpu);
            if Totals.player - Totals.cpu < 0; score_color = [255, 0, 0, 255]; end
            if Totals.player - Totals.cpu > 0; score_msg = sprintf(' +%d', Totals.player - Totals.cpu); end

            Screen('TextSize', Screen_Pars.window, Text_Size.score_totals);
            DrawFormattedText2('Total ', 'win', Screen_Pars.window, 'sx', 'center', ...
                               'sy', Screen_Pars.window_height - 5, 'xalign', 'right', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', white);
            DrawFormattedText2(score_msg, 'win', Screen_Pars.window, 'sx', 'center', ...
                               'sy', Screen_Pars.window_height - 5, 'xalign', 'left', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', score_color);
    end
end