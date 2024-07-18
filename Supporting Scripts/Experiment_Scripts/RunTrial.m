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
%   - trial_events  (The events that occured during this trial and their time)   
%   - extras        (struct to store extra things)

function [player_data, cpu_data, Totals, trial_events, extras] = RunTrial(Parameters, Disbtn, Button_Scores, Cpu, Totals, Block_Idx, Trial_Idx)
    %% PRE STAGE - Before the timer of the activity starts
    % Create a trial Start event
    trial_events = CreateEvent("trialStart", Block_Idx, Trial_Idx);

    % Initialize some of the variables we need for storing
    player_data = struct('time',NaN, 'score', NaN, 'choice', NaN);
    cpu_data = struct('score', NaN, 'choice', NaN);
    pd_s = Parameters.trial.photodiode_dur_s;
    abort = false;
    archived_button_scores = [];
    archived_score_means = [];
    archived_mhb_dist = [];
    block_change_logs = NaN;
    
    [pl_events, cpu_events] = deal([]);


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
    %     DrawIcon(Parameters.screen.window, ['PlAv', num2str(Parameters.Pars.avatars.player), '.png'], player_rect);
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
        [player_data, Totals, pl_events, abort] = playerTurn(Parameters, Disbtn.player, Button_Scores, Totals, ...
                                                      Cpu, Block_Idx, 2*Trial_Idx-1, pd_s);
        if ~abort
            % Update the scores because I suddenly need to mid trial 
            [Button_Scores, block_change_logs, score_means, mhb_dist] = GetScores(Parameters.target.button_names, ...  % The scores for each button
                                                                          Parameters.target.score_change_rng,...
                                                                          Disbtn.player, false);
            archived_score_means = score_means;
            archived_button_scores = Button_Scores;
            archived_mhb_dist = mhb_dist;
           
            % Carry out the Cpu's turn
            [cpu_data, Totals, cpu_events] = cpuTurn(Parameters, Disbtn.cpu, Button_Scores, Cpu, Totals,...
                                                     Block_Idx, 2*Trial_Idx, pd_s);
        end
        trial_events = [trial_events; pl_events; cpu_events];
    else
        [cpu_data, Totals, cpu_events] = cpuTurn(Parameters, Disbtn.cpu, Button_Scores, Cpu, Totals,...
                                                 Block_Idx, 2*Trial_Idx-1, pd_s);
        % Update the scores because I suddenly need to mid trial 
        [Button_Scores, block_change_logs, score_means, mhb_dist] = GetScores(Parameters.target.button_names, ...  % The scores for each button
                                                                      Parameters.target.score_change_rng, ...
                                                                      Disbtn.player, false);
        archived_score_means = score_means;
        archived_button_scores = Button_Scores;
        archived_mhb_dist = mhb_dist;
        
        % Carry out the player's turn
        [player_data, Totals, pl_events, abort] = playerTurn(Parameters, Disbtn.player, Button_Scores, Totals, ...
                                                      Cpu, Block_Idx, 2*Trial_Idx, pd_s);
        trial_events = [trial_events; cpu_events; pl_events];
    end

    if Trial_Idx ~= Parameters.trial.num && ~abort
        [Button_Scores, block_change_logs, score_means] = GetScores(Parameters.target.button_names, ...  % The scores for each button
                                                                    Parameters.target.score_change_rng, ...
                                                                    Disbtn.player, false);
        archived_score_means = [archived_score_means; score_means];
        archived_button_scores = [archived_button_scores; Button_Scores];
        archived_mhb_dist = [archived_mhb_dist; mhb_dist];
    end

    trial_events = [trial_events; CreateEvent("trialEnd", Block_Idx, Trial_Idx)];
    extras = struct("abort", abort, 'button_scores', Button_Scores, 'archived_sm', archived_score_means, ...
                    "archived_bs", archived_button_scores, "block_cl", block_change_logs, ...
                    "archived_mhb", archived_mhb_dist);
end


%% HELPER FUNCTIONS
% playerTurn - Function for the turn of the player
% Arguments:
%   - Pars          (The experiment parameters)
%   - Disbtn        (The buttons disabled for the player and cpu)
%   - Button_Scores (The score values of  each button)
%   - Totals        (The total scores of the cpu and player)
%   - Cpu           (A pointer to the cpu handle)
%   - Block_Idx     (Which block we are on)
%   - Trial_Idx     (Which trial we are on)
%   - PD_S          (The duration of the photodiode in seconds)
% Outputs: 
%   - pl_data       (Data on the player's performance)
%   - Totals        (The updated Totals initially provided)
%   - events        (A list of the events that happened during the player's turn)   
function [pl_data, Totals, events, abort] = playerTurn(Pars, Disbtn, Button_Scores, Totals, Cpu, Block_Idx, Trial_Idx, PD_S)
    %% PRE CALCULATIONS FOR THE PLAYER TURN
    events = CreateEvent("playerTurnStart", Block_Idx, Trial_Idx);
    pl_data = struct('time',NaN, 'score', NaN, 'choice', NaN);
    abort = false;

    load("colors.mat", "color_list");
    disp("Player turn ")
    choice_idx = -1;

    % Variables for loop control
    break_loop = false;
    [pause_offset, score] = deal(0);
    start = GetSecs();
    elapsed_time = GetSecs() - start;
    first_loop_pd = true;       % First loop with the photodiode drawing
    first_loop_npd = true;      % First loop without the photodiode drawing
    
    a_key = KbName('A');
    b_key = KbName('B');
    x_key = KbName('X');
    y_key = KbName('Y');
    p_key = KbName('P');
    esc_key = KbName('ESCAPE');
    choice = table('Size', [1,4],'VariableNames', string(Pars.target.button_names')', 'VariableTypes', repmat("logical", 1,4));

    %% LOOP PHASE - player will be making their choice
    while ~break_loop
        % Get the time
        elapsed_time = GetSecs()-pause_offset-start;

        % Get the player's input
        pl_ci = GetXBox();          % pl_ci = player controller input
        [~,~,ex_ki] = KbCheck();    % ex_ki = experimenter keyboard input
        keep_drawing = pl_ci.A || pl_ci.B || pl_ci.X || pl_ci.Y || pl_ci.Start || ...
                       ex_ki(a_key) || ex_ki(b_key) || ex_ki(x_key) || ex_ki(y_key) || ...
                       ex_ki(p_key) || ex_ki(esc_key);
        
        % Draw the photodiode if this is the best time
        % Also skip if no player input was provided to save memory;
        if elapsed_time < PD_S
            if first_loop_pd
                first_loop_pd = false;
                disp('a')
            else
                if ~keep_drawing; continue; end
            end
            DrawPhotoDiode(Pars); 
        else
            if first_loop_npd
                first_loop_npd = false;
                disp('b')
            else
                if ~keep_drawing; continue; end
            end
        end

        if pl_ci.Start || ex_ki(p_key)
            events = [events; CreateEvent("taskPause", Block_Idx, Trial_Idx)];
            pause_offset = pauseGame(Pars, pause_offset);
            events = [events; CreateEvent("taskResume", Block_Idx, Trial_Idx)];
        elseif ex_ki(esc_key)
            events = [events; CreateEvent("taskAbort", Block_Idx, Trial_Idx)];
            abort = true;
            return;
        end

        % Get the choice
        choice.A = pl_ci.A || ex_ki(a_key);
        choice.B = pl_ci.B || ex_ki(b_key);
        choice.X = pl_ci.X || ex_ki(x_key);
        choice.Y = pl_ci.Y || ex_ki(y_key);
        
        % Draw the Pars.avatars and any extra stuff
        drawExtras(Pars, Cpu, Totals, Trial_Idx, false);
        
        % Draw each button
        for button_idx = 1:length(Pars.target.button_names)
            % Get the color of the button
            color = Pars.target.colors(button_idx,:);

            % In case we have selected a button to press, do these steps
            if choice.(Pars.target.button_names(button_idx)) && ~break_loop
                color = color/0.8; 

                % If the button is eligible, act accordingly     
                if ~strcmpi(Pars.target.button_names(button_idx), Disbtn)
                    DrawPhotoDiode(Pars); % Draw the photodiode for the event
                    events=[events; CreateEvent("playerDecisionMade", Block_Idx, Trial_Idx)];
                    
                    % Store the choice, the score and update the totals.
                    pl_choice = Pars.target.button_names(button_idx);
                    choice_idx = button_idx;
                    score = Button_Scores(button_idx);
                    Totals.player = Totals.player + score;
                    
                    % Inform the script that the loop should be broken
                    break_loop = true;
                end
            end
            
            % Create the circle to be drawn for the target. Draw a ring if the player has pressed the target     
            Screen('FillOval',Pars.screen.window, color, Pars.target.rects(button_idx,:));
            if choice.(Pars.target.button_names(button_idx)) && break_loop 
                Screen('FrameOval',Pars.screen.window, repmat(255,1,4), Pars.target.ring_rects(button_idx,:), 10);
            end
            
            % Draw the Letters of the buttons
            DrawIcon(Pars, ['Letter_', Pars.target.button_names(button_idx), '.png'],...
                Pars.target.rects(button_idx,:));
            
            % If the button is disabled, draw a semi-transparent circle over it to gray it out.     
            if strcmpi(Pars.target.button_names(button_idx), Disbtn)
                Screen('FillOval',Pars.screen.window, [20, 20, 20, 230], Pars.target.ring_rects(button_idx,:));
            end
        end
        % Output the imagery
        Screen('Flip', Pars.screen.window);
        
        % Update the elapsed time and exit the loop if needed
        elapsed_time = GetSecs()-pause_offset-start;
        if break_loop; break; end
    end
    WaitSecs(PD_S); % Wait for the photodiode to shine
    
    %% SHOW THE SCORES THE PLAYER HAS GOTTEN
    % Draw the Pars.avatars and any extra stuff
    drawExtras(Pars, Cpu, Totals, Trial_Idx, false);
    
    % Draw each button
    for button_idx = 1:length(Pars.target.button_names)
        % Get the color and highlight it if selected
        color = Pars.target.colors(button_idx,:);
        if button_idx == choice_idx; color = color/0.8; end

        % Create the circle to be drawn for the target
        Screen('FillOval',Pars.screen.window, color, Pars.target.rects(button_idx,:));

        % If the score is to be shown, draw the score and the ring. Otherwise draw the button letter
        if button_idx == choice_idx
            Screen('TextSize', Pars.screen.window, Pars.text.size.button_score);
            DrawFormattedText2(num2str(score), 'win', Pars.screen.window, 'sx', Pars.target.coords(button_idx, 1), ...
                'sy', Pars.target.coords(button_idx, 2), 'xalign', 'center', 'yalign','center',...
                'baseColor', color_list.white);
            Screen('FrameOval',Pars.screen.window, repmat(255,1,4), Pars.target.ring_rects(button_idx,:), 10);
        else
            DrawIcon(Pars, ['Letter_', Pars.target.button_names(button_idx), '.png'],...
                Pars.target.rects(button_idx,:));
        end

        % If the button is disabled, draw a semi-transparent circle over it to gray it out.
        if strcmpi(Pars.target.button_names(button_idx), Disbtn)
            Screen('FillOval',Pars.screen.window, [20, 20, 20, 230], Pars.target.ring_rects(button_idx,:));
        end
    end
    Screen('Flip', Pars.screen.window);
    
    % Get the data for the player to be returned
    pl_data = struct('time',elapsed_time, 'score', score, 'choice', pl_choice);
    WaitSecs(1);
    events = [events; CreateEvent("playerTurnEnd", Block_Idx, Trial_Idx)];
end


%function pauseGame - Pause the Game while the player is playing
% Arguments: 
%   - Pars          (The experiment parameters)
%   - Pause_Offset  (How long we have paused so far)
% Return:
%   - Pause_Offset  (How long we have paused so far)
function Pause_Offset = pauseGame(Pars, Pause_Offset)
    % Start timing the pause
    offset_start = GetSecs();
    WaitSecs(0.3);
    
    % Let the player know the game is paused
    Screen('TextSize', Pars.screen.window, Pars.text.size.scores);
    msg = 'Game is paused.\nPress Start on the controller, or P on the keyboard to unpause.';
    DrawFormattedText2(msg, 'win', Pars.screen.window, 'sx', 'center', 'sy', 'center', ...
                       'xalign', 'center', 'baseColor', repmat(255, 1, 4));
    Screen('Flip', Pars.screen.window);
    
    % Wait for input
    while true
        pl_ci = GetXBox();
        [~, ~, ex_ki] = KbCheck();
        
        if pl_ci.Start || ex_ki(KbName('P')); break; end
    end
    WaitSecs(0.3);
    disp(Pause_Offset);

    % Note the time passed
    Pause_Offset = Pause_Offset + (GetSecs() - offset_start);
    disp(Pause_Offset);
end


% cpuTurn - Function for the turn of the cpu
% Arguments:
%   - Pars          (The experiment parameters)
%   - Disbtn        (The buttons disabled for the player and cpu)
%   - Button_Scores (The score values of  each button)
%   - Cpu           (A pointer to the cpu handle)
%   - Totals        (The total scores of the cpu and player)
%   - Block_Idx     (Which block we are on)
%   - Trial_Idx     (Which trial we are on)
%   - PD_S          (The duration of the photodiode in seconds)
% Outputs: 
%   - cpu_data      (Data on the cpu's performance)
%   - Totals        (The updated Totals initially provided)
%   - events        (A list of the events that happened during the player's turn)   
function [cpu_data, Totals, events] = cpuTurn(Pars, Disbtn, Button_Scores, Cpu, Totals, Block_Idx, Trial_Idx, PD_S)
    %% PRE-CALCULATIONS FOR CPU TURN
    events = CreateEvent("cpuTurnStart", Block_Idx, Trial_Idx);

    % Determine how long the cpu will wait to emulate decision making
    cpu_time = rand()* Pars.trial.cpu_wait_dur + Pars.trial.cpu_wait_s(1);
    
    % Note the event of the cpu beginning its turn
    % disp("Cpu - prechoice")
    % events = {sprintf('Block %d Trial %d - CPU Turn Start', Block_Idx, Trial_Idx), GetSecs()};
    
    %% CPU PRECHOICE ILLUSTRATIONS
    % PHOTODIODE MODE
    pd_mode_start = GetSecs();

    % Draw the background and the board
    drawExtras(Pars, Cpu, Totals, Trial_Idx, true); 
    cpuDrawPart1(Pars, Disbtn, true);
    
    % Wait until the photodiode needs to be drawn no longer    
    WaitSecs(max(0, PD_S - (GetSecs() - pd_mode_start)));
    
    % NON PHOTODIODE MODE
    npd_mode_start = GetSecs();

    % Draw the background and the board
    drawExtras(Pars, Cpu, Totals, Trial_Idx, true);
    cpuDrawPart1(Pars, Disbtn, false);
    
    % Calculate the cpu's choice and its outcomes
    cpu_choice = Cpu.getResponse(Button_Scores);
    score_idx = Pars.target.button_names == cpu_choice;
    cpu_score = Button_Scores(score_idx);
    Totals.cpu = Totals.cpu + cpu_score;
    Cpu.changeBehavior(cpu_score);
    
    % Wait until the cpu's wait time has finished
    WaitSecs(max(0, cpu_time - PD_S - (GetSecs() - npd_mode_start)));
    events = [events; CreateEvent("cpuDecisionMade", Block_Idx, Trial_Idx)];
    
    %% CPU POSTCHOICE ILLUSTRATIONS
    % Make a note of the cpu's choice as an event
    disp("Cpu - postchoice")
    % events = [events;{sprintf('Block %d Trial %d - CPU Turn Choice', Block_Idx, Trial_Idx), GetSecs()};];

    % PHOTODIODE MODE
    pd_mode_start = GetSecs();

    % Draw the Pars.avatars and board
    drawExtras(Pars,Cpu, Totals, Trial_Idx, true);
    cpuDrawPart2(Pars, Disbtn, cpu_choice, cpu_score, true); % photodiode event
    
    % Wait until the photodiode needs to be drawn no longer    
    WaitSecs(max(0, PD_S - (GetSecs() - pd_mode_start)));
    
    % NON PHOTODIODE MODE
    % Draw the Pars.avatars and board
    drawExtras(Pars, Cpu, Totals, Trial_Idx, true);
    cpuDrawPart2(Pars, Disbtn, cpu_choice, cpu_score, false);
    WaitSecs(1);
    
    % save the data of the turn
    cpu_data = struct('score', cpu_score, 'choice', cpu_choice);
    events = [events; CreateEvent("cpuTurnEnd", Block_Idx, Trial_Idx)];
end

% cpuDrawPart1 - Drawing before the cpu makes a choice
% Arguments:
%   - Pars              (The parameters for the experiment)
%   - Disbtn            (The buttons disabled for the player and cpu)
%   - Show_PhotoDiode   (If the photodiode should be shown)
% Outputs: None
function cpuDrawPart1(Pars, Disbtn, Show_PhotoDiode)
    % Draw each button
    for button_idx = 1:length(Pars.target.button_names)
        % Get the color of the button
        color = Pars.target.colors(button_idx,:);
        
        % Draw the button and its letter
        Screen('FillOval',Pars.screen.window, color, Pars.target.rects(button_idx,:));
        DrawIcon(Pars, ['Letter_', Pars.target.button_names(button_idx), '.png'],...
                 Pars.target.rects(button_idx,:));
        
        % Obscure the disabled button
        if strcmpi(Pars.target.button_names(button_idx), Disbtn)
            Screen('FillOval',Pars.screen.window, [20, 20, 20, 230], Pars.target.ring_rects(button_idx,:));
        end
    end
    
    % If the photodiode is to be shown, do it
    if Show_PhotoDiode; DrawPhotoDiode(Pars); end
    
    % Put everything on screen
    Screen('Flip', Pars.screen.window);
end

% cpuDrawPart2 - Drawing after the cpu makes a choice
% Arguments:
%   - Pars              (The Parameters for the experiment)
%   - Disbtn            (The buttons disabled for the player and cpu)
%   - Cpu_Choice        (The choice (letter) of the cpu)
%   - Cpu_Score         (The score the cpu got from its choice
%   - Show_PhotoDiode   (If the photodiode should be shown)
% Outputs: None
function cpuDrawPart2(Pars, Disbtn, Cpu_Choice, Cpu_Score, Show_PhotoDiode)
    % Draw each button
    for button_idx = 1:length(Pars.target.button_names)
        % Get the color and initialize a decision
        show_score = false;
        color = Pars.target.colors(button_idx,:);
        
        % If the cpu chose this button update the previous values
        if strcmpi(Pars.target.button_names(button_idx), Cpu_Choice)
            if ~strcmpi(Pars.target.button_names(button_idx), Disbtn)
                color = color / 0.8;
                show_score = true;
            end
        end
        
        % Draw the buttons and either its letter or the score with a ring (if this is the chosen button) 
        Screen('FillOval',Pars.screen.window, color, Pars.target.rects(button_idx,:));
        if show_score
            Screen('FrameOval',Pars.screen.window, repmat(255,1,4), Pars.target.ring_rects(button_idx,:), 10);
        end
        if show_score && ~Show_PhotoDiode
            Screen('TextSize', Pars.screen.window, Pars.text.size.button_score);
            DrawFormattedText2(num2str(Cpu_Score), 'win', Pars.screen.window, 'sx', Pars.target.coords(button_idx, 1), ...
                               'sy', Pars.target.coords(button_idx, 2), 'xalign', 'center', 'yalign','center',...
                               'baseColor', [0,0,0,255]);
        else
            DrawIcon(Pars, ['Letter_', Pars.target.button_names(button_idx), '.png'],...
                     Pars.target.rects(button_idx,:));
        end
        
        % If this is the disabled button, obscure it
        if strcmpi(Pars.target.button_names(button_idx), Disbtn)
            Screen('FillOval', Pars.screen.window, [20, 20, 20, 230], Pars.target.ring_rects(button_idx,:));
        end
    end

    % If the photodiode is to be drawn, do it
    if Show_PhotoDiode; DrawPhotoDiode(Pars); end
    
    % Present everything
    Screen('Flip', Pars.screen.window);
end

% drawExtras - Draws the Avatars, scores, and score mode    
% Arguments:
%   - Pars          (The Parameters for the experiment)
%   - Totals        (The total scores of the cpu and player)
%   - Trial_Idx     (Which trial we are on)
%   - Hide_Player   (If the player should be hiden. True in Cpu's turn. False in  player's turn.)     
% Outputs: None
function drawExtras(Pars, Cpu, Totals, Trial_Idx, Hide_Player)
    white = repmat(255, 1, 4);

    % Draw the Score Mode
    score_mode_rect = [0, 0, Pars.screen.window_width, Pars.text.size.score_mode + 10];
    score_mode_color = [200, 200, 0, 255];
    switch lower(Cpu.Score_Mode)
        case 'cooperative'; score_mode_color = [0, 0, 255, 255];
        case 'competitive'; score_mode_color = [255, 0, 0, 255];
    end
    Screen('TextSize', Pars.screen.window, Pars.text.size.score_mode);
    Screen('FillRect', Pars.screen.window, score_mode_color, score_mode_rect);
    DrawFormattedText2(char(Cpu.Score_Mode), 'win', Pars.screen.window, 'sx', 'center', 'sy', 5, ...
                       'xalign', 'center', 'baseColor', white);

    % Draw the Trial Number
    Screen('TextSize', Pars.screen.window, Pars.text.size.turn_order);
    DrawFormattedText2(sprintf('Trial %d :', Trial_Idx), 'win', Pars.screen.window, 'sx', 'center', ...
                       'sy', Pars.text.size.score_mode + 15, 'xalign', 'right', 'baseColor', white); 
    
    % Draw out the Pars.avatars
    DrawIcon(Pars, ['PlAv', num2str(Pars.avatars.player), '.png'], Pars.avatars.player_rect);
    DrawIcon(Pars, ['CpuAv', num2str(Cpu.Behavior_Mode), '.png'], Pars.avatars.cpu_rect);

    % See which entity to hide
    if Hide_Player
        Screen('FillRect', Pars.screen.window, [50, 50, 50, 200], Pars.avatars.player_gray_rect);
        Screen('FrameRect', Pars.screen.window, [0, 255, 0, 255], Pars.avatars.cpu_rect, 5);
        DrawFormattedText2(['  ', Cpu.Name], 'win', Pars.screen.window, 'sx', 'center', 'sy', Pars.text.size.score_mode + 15 , ...
                           'xalign', 'left', 'baseColor', [204, 50, 50, 255]); 
    else
        Screen('FillRect', Pars.screen.window, [50, 50, 50, 200], Pars.avatars.cpu_gray_rect);
        Screen('FrameRect', Pars.screen.window, [0, 255, 0, 255], Pars.avatars.player_rect, 5);
        DrawFormattedText2('  You', 'win', Pars.screen.window, 'sx', 'center', 'sy', Pars.text.size.score_mode + 15,  ...
                           'xalign', 'left', 'baseColor', [45, 201, 55, 255]); 
    end
    
    % Draw the textboxes for the player and the CPU
    Screen('FillRect', Pars.screen.window, [50, 50, 50, 200], Pars.avatars.player_textbox_rect);
    Screen('FillRect', Pars.screen.window, [50, 50, 50, 200], Pars.avatars.cpu_textbox_rect);

    % Display the titles for the player and the CPU
    title_sy = (Pars.text.size.score_mode + 10) + (Pars.avatars.avatar_height-7);
    Screen('TextSize', Pars.screen.window, Pars.text.size.title);
    DrawFormattedText2('You', 'win', Pars.screen.window, 'sx', Pars.avatars.avatar_width/2, 'sy', title_sy,...
                       'xalign', 'center', 'yalign', 'bottom', 'baseColor', white);
    DrawFormattedText2(Cpu.Name, 'win', Pars.screen.window, 'sx', Pars.screen.window_width-Pars.avatars.avatar_width/2, ...
                       'sy', title_sy, 'xalign', 'center', 'yalign', 'bottom', 'baseColor', white);
    
    % Display the scores, based on the score mode of the cpu
    Screen('TextSize', Pars.screen.window, Pars.text.size.scores);
    % player
    DrawFormattedText2('Score', 'win', Pars.screen.window, 'sx', Pars.avatars.avatar_width + 15, ...
                        'sy', Pars.text.size.score_mode + 10 + Pars.text.size.scores, 'yalign', 'bottom', ...
                        'baseColor', white);
    DrawFormattedText2(num2str(Totals.player), 'win', Pars.screen.window, 'sx', Pars.avatars.avatar_width + 15, ...
                       'sy', Pars.text.size.score_mode + 10 + Pars.text.size.scores*2, 'yalign', 'bottom', 'baseColor', white);
    
    if ~strcmpi (Cpu.Score_Mode, "Indifferent")
        DrawFormattedText2('Score', 'win', Pars.screen.window, 'sx', Pars.avatars.left_avatar_xstart - 15, ...
            'sy', Pars.text.size.score_mode + 10 + Pars.text.size.scores, 'xalign', 'right', ...
            'yalign', 'bottom', 'baseColor', white);
        DrawFormattedText2(num2str(Totals.cpu), 'win', Pars.screen.window, 'sx', Pars.avatars.left_avatar_xstart - 15,...
            'sy', Pars.text.size.score_mode + 10 + Pars.text.size.scores*2, 'xalign', 'right', ...
            'yalign', 'bottom', 'baseColor', white);
    end

    % Make displays based on the CPU score mode
    switch lower(Cpu.Score_Mode)
        case 'cooperative'
            Screen('TextSize', Pars.screen.window, Pars.text.size.score_totals);
            score_msg = sprintf(' %d', Totals.player + Totals.cpu);
            DrawFormattedText2('Total ', 'win', Pars.screen.window, 'sx', 'center', ...
                               'sy', Pars.screen.window_height - 5, 'xalign', 'right', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', white);
            DrawFormattedText2(score_msg, 'win', Pars.screen.window, 'sx', 'center', ...
                               'sy', Pars.screen.window_height - 5, 'xalign', 'left', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', [0, 0, 255, 255]);
        case 'competitive'
            score_color = [50,50,255,255];
            score_msg = sprintf(' %d', Totals.player - Totals.cpu);
            if Totals.player - Totals.cpu < 0; score_color = [255, 0, 0, 255]; end
            if Totals.player - Totals.cpu > 0; score_msg = sprintf(' +%d', Totals.player - Totals.cpu); end

            Screen('TextSize', Pars.screen.window, Pars.text.size.score_totals);
            DrawFormattedText2('Total ', 'win', Pars.screen.window, 'sx', 'center', ...
                               'sy', Pars.screen.window_height - 5, 'xalign', 'right', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', white);
            DrawFormattedText2(score_msg, 'win', Pars.screen.window, 'sx', 'center', ...
                               'sy', Pars.screen.window_height - 5, 'xalign', 'left', 'yalign', 'bottom',...
                               'xlayout', 'right', 'baseColor', score_color);
    end
end