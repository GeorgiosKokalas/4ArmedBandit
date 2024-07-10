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

function [player_data, cpu_data, Totals, trial_events] = RunTrial(Parameters, Disbtn, Button_Scores, Cpu, Totals, Block_Idx, Trial_Idx)
    %% PRE STAGE - Before the timer of the activity starts
    % Initialize some of the variables we need for storing
    
    % [pl_score, cpu_score] = deal(0);
    % [pl_choice, cpu_choice] = deal('Void');
    % pl_time = -1;
    % trial_events = {};
    pd_s = Parameters.trial.photodiode_dur_s;


    %% PRESENTATION STAGE - The trial begins    
    % Flip a coin on who starts first
    disp("NEW TRIAL")
    if rand() < 0.5
        [player_data, Totals, pl_events] = player_turn(Parameters.screen, Parameters.target,...
                                                       Disbtn.player, Button_Scores, Totals, ...
                                                       Parameters.text.size, Parameters.avatars, Cpu.Behavior_Mode,...
                                                       Block_Idx, Trial_Idx, Parameters.trial.photodiode_dur_s);
        [cpu_data, Totals, cpu_events] = cpu_turn(Parameters.screen, Parameters.target, Parameters.trial,...
                                                   Disbtn.cpu, Button_Scores, Cpu, Totals,...
                                                   Parameters.text.size, Parameters.avatars,...
                                                   Block_Idx, Trial_Idx, Parameters.trial.photodiode_dur_s);
        trial_events = [pl_events; cpu_events];
    else
        [cpu_data, Totals, cpu_events] = cpu_turn(Parameters.screen, Parameters.target, Parameters.trial,...
                                                   Disbtn.cpu, Button_Scores, Cpu, Totals,...
                                                   Parameters.text.size, Parameters.avatars,...
                                                   Block_Idx, Trial_Idx, Parameters.trial.photodiode_dur_s);
        [player_data, Totals, pl_events] = player_turn(Parameters.screen, Parameters.target,...
                                                       Disbtn.player, Button_Scores, Totals, ...
                                                       Parameters.text.size, Parameters.avatars, Cpu.Behavior_Mode,...
                                                       Block_Idx, Trial_Idx, Parameters.trial.photodiode_dur_s);
        trial_events = [cpu_events; pl_events];
    end


    
    %% POST STAGE - compile the data for export
    % cpu_data = struct('score', cpu_score, 'choice', cpu_choice);
end


%% HELPER FUNCTIONS
function [pl_data, Totals, events] = player_turn(Screen_Pars, Targ_Pars, Disbtn, Button_Scores, Totals, Text_Size, Avatars, Cpu_Num, Block_Idx, Trial_Idx, PD_S)
    load("colors.mat", "color_list");
    disp("Player turn ")
    choice_idx = -1;

    % Variables for loop control
    break_loop = false;
    [pause_offset, score] = deal(0);
    start = GetSecs();
    elapsed_time = GetSecs() - start;

    events = {sprintf('Block %d Trial %d - Player Turn Start', Block_Idx, Trial_Idx), GetSecs()};
    while ~break_loop
        pc_input = GetXBox();

        % Draw the photodiode
        if elapsed_time < PD_S; DrawPhotoDiode(Screen_Pars); end
        
        % Draw the Avatar
        drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu_Num, Totals, false);
        
        % Draw each Button
        for button_idx = 1:length(Targ_Pars.button_names)
            color = Targ_Pars.colors(button_idx,:);

            % In case we have selected a button to press, do these steps
            if pc_input.(Targ_Pars.button_names(button_idx)) && ~break_loop
                color = color/0.8; 

                % If the button is eligible, notify the script 
                if ~strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                    DrawPhotoDiode(Screen_Pars);
                    events = [events;{sprintf('Block %d Trial %d - Player Turn Choice', Block_Idx, Trial_Idx), GetSecs()}];
                    choice = Targ_Pars.button_names(button_idx);
                    choice_idx = button_idx;
                    score = Button_Scores(button_idx);
                    break_loop = true;
                    Totals.player = Totals.player + score;
                end
            end
            
            % Create the circle to be drawn for the target
            Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));
            
            % Draw the Letters of the buttons
            DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                Targ_Pars.rects(button_idx,:));
            
            % If the button is disabled, draw a semi-transparent circle over it to gray it out.     
            if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                Screen('FillOval',Screen_Pars.window, [50, 50, 50, 210], Targ_Pars.rects(button_idx,:));
            end
        end
        
        Screen('Flip', Screen_Pars.window);
        
        elapsed_time = GetSecs()-pause_offset-start;
        if break_loop; break; end
    end
    WaitSecs(PD_S); % Wait for the photodiode to Shine
    
    % SHOW THE SCORES THE PLAYER HAS GOTTEN
    % Draw the Avatar 
    drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu_Num, Totals, false);
    
    for button_idx = 1:length(Targ_Pars.button_names)
        % Get the color and highlight it if selected
        color = Targ_Pars.colors(button_idx,:);
        if button_idx == choice_idx; color = color/0.8; end

        % Create the circle to be drawn for the target
        Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));

        % If the score is to be shown, draw the score. Otherwise draw the button letter
        if button_idx == choice_idx
            Screen('TextSize', Screen_Pars.window, Text_Size.button_score);
            DrawFormattedText2(num2str(score), 'win', Screen_Pars.window, 'sx', Targ_Pars.coords(button_idx, 1), ...
                'sy', Targ_Pars.coords(button_idx, 2), 'xalign', 'center', 'yalign','center',...
                'baseColor', color_list.white);
        else
            DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                Targ_Pars.rects(button_idx,:));
        end

        % If the button is disabled, draw a semi-transparent circle over it to gray it out.
        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval',Screen_Pars.window, [50, 50, 50, 210], Targ_Pars.rects(button_idx,:));
        end
    end
    Screen('Flip', Screen_Pars.window);
    
    % Get the data for the player to be returned
    pl_data = struct('time',elapsed_time, 'score', score, 'choice', choice);
    WaitSecs(1);
end


function [cpu_data, Totals, events] = cpu_turn(Screen_Pars, Targ_Pars, Trial_Pars, Disbtn, Button_Scores, Cpu, Totals, Text_Size, Avatars, Block_Idx, Trial_Idx, PD_S)
    load("colors.mat", "color_list");
    cpu_time = rand()* Trial_Pars.cpu_wait_dur + Trial_Pars.cpu_wait_s(1);

    disp("Cpu - prechoice")
    events = {sprintf('Block %d Trial %d - CPU Turn Start', Block_Idx, Trial_Idx), GetSecs()};
    
    % Draw the Avatar
    drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu.Behavior_Mode, Totals, true);
    cpuDrawPart1(Screen_Pars, Targ_Pars, Disbtn, true);
    WaitSecs(PD_S);
    drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu.Behavior_Mode, Totals, true);
    cpuDrawPart1(Screen_Pars, Targ_Pars, Disbtn, false);
    
    cpu_choice = Cpu.getResponse();
    score_idx = Targ_Pars.button_names == cpu_choice;
    cpu_score = Button_Scores(score_idx);
    Totals.cpu = Totals.cpu + cpu_score;
    Cpu.changeBehavior(cpu_score);
    
    WaitSecs(max(0, cpu_time - PD_S));
    events = [events;{sprintf('Block %d Trial %d - CPU Turn Choice', Block_Idx, Trial_Idx), GetSecs()};];
    
    disp("Cpu - postchoice")
    % Draw the Avatar
    drawAvatars(Screen_Pars, Avatars, Text_Size,Cpu.Behavior_Mode, Totals, true);
    cpuDrawPart2(Screen_Pars, Targ_Pars, Disbtn, cpu_choice, cpu_score, Text_Size, true);
    WaitSecs(PD_S);
    drawAvatars(Screen_Pars, Avatars, Text_Size,Cpu.Behavior_Mode, Totals, true);
    cpuDrawPart2(Screen_Pars, Targ_Pars, Disbtn, cpu_choice, cpu_score, Text_Size, false);

    WaitSecs(1);

    cpu_data = struct('score', cpu_score, 'choice', cpu_choice);
end

function cpuDrawPart1(Screen_Pars, Targ_Pars, Disbtn, Show_PhotoDiode)
    for button_idx = 1:length(Targ_Pars.button_names)
        color = Targ_Pars.colors(button_idx,:);
        
        Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));

        DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                 Targ_Pars.rects(button_idx,:));

        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval',Screen_Pars.window, [50, 50, 50, 210], Targ_Pars.rects(button_idx,:));
        end
    end

    if Show_PhotoDiode; DrawPhotoDiode(Screen_Pars); end

    Screen('Flip', Screen_Pars.window);
end

function cpuDrawPart2(Screen_Pars, Targ_Pars, Disbtn, Cpu_Choice, Cpu_Score, Text_Size, Show_PhotoDiode)
    for button_idx = 1:length(Targ_Pars.button_names)
        show_score = false;
        color = Targ_Pars.colors(button_idx,:);

        if strcmpi(Targ_Pars.button_names(button_idx), Cpu_Choice)
            if ~strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                color = color / 0.8;
                show_score = true;
            end
        end

        Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));
        if show_score && ~Show_PhotoDiode
            Screen('TextSize', Screen_Pars.window, Text_Size.button_score);
            DrawFormattedText2(num2str(Cpu_Score), 'win', Screen_Pars.window, 'sx', Targ_Pars.coords(button_idx, 1), ...
                               'sy', Targ_Pars.coords(button_idx, 2), 'xalign', 'center', 'yalign','center',...
                               'baseColor', [0,0,0,255]);
        else
            DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                     Targ_Pars.rects(button_idx,:));
        end

        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval', Screen_Pars.window, [50, 50, 50, 210], Targ_Pars.rects(button_idx,:));
        end
    end
    if Show_PhotoDiode; DrawPhotoDiode(Screen_Pars); end

    Screen('Flip', Screen_Pars.window);
end


% function that draws the player and Cpu's avatars
function drawAvatars(Screen_Pars, Avatars, Text_Size, Cpu_Num, Totals, Hide_Player)
    % Creating some useful variables
    a_width = Screen_Pars.window_width / 6;             % The width of the avatar  
    a_height = Screen_Pars.window_height / 4;           % The height of the avatat     
    cpu_ax_start = Screen_Pars.window_width - a_width;  % The x coordinate where the cpu avatar starts    

    player_rect = [0,0, a_width, a_height];
    player_textbox_rect = [0, a_height-(Text_Size.title+10), a_width, a_height];
    player_gray_rect = [0,0, a_width, a_height-(Text_Size.title+10)];
    
    cpu_rect = [cpu_ax_start, 0, Screen_Pars.window_width, a_height];
    cpu_textbox_rect = [cpu_ax_start, a_height-(Text_Size.title+10), Screen_Pars.window_width, a_height];
    cpu_gray_rect = [cpu_ax_start, 0, Screen_Pars.window_width, a_height-(Text_Size.title+10)];
    
    % Draw out the avatars
    DrawIcon(Screen_Pars.window, ['PlAv', num2str(Avatars.player), '.png'], player_rect);
    DrawIcon(Screen_Pars.window, ['CpuAv', num2str(Cpu_Num), '.png'], cpu_rect);
    
    
    % Draw the title, and scores for the player
    Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], player_textbox_rect);
    Screen('TextSize', Screen_Pars.window, Text_Size.title);
    DrawFormattedText2('You', 'win', Screen_Pars.window, 'sx', a_width/2, 'sy', a_height-7,...
                       'xalign', 'center', 'yalign', 'bottom', 'baseColor', 252:255);
    Screen('TextSize', Screen_Pars.window, Text_Size.scores);
    DrawFormattedText2('Score', 'win', Screen_Pars.window, 'sx', a_width, 'sy', Text_Size.scores, ...
                       'yalign', 'bottom', 'baseColor', 252:255);
    DrawFormattedText2(num2str(Totals.player), 'win', Screen_Pars.window, 'sx', a_width, 'sy', Text_Size.scores*2, ...
                       'yalign', 'bottom', 'baseColor', 252:255);
    
    % Draw the title, and scores for the cpu
    Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], cpu_textbox_rect);
    Screen('TextSize', Screen_Pars.window, Text_Size.title);
    DrawFormattedText2(sprintf('Opponent %d', Cpu_Num), 'win', Screen_Pars.window,...
                       'sx', Screen_Pars.window_width-a_width/2, 'sy', a_height-7, 'xalign', 'center',...
                       'yalign', 'bottom', 'baseColor', 252:255);
    Screen('TextSize', Screen_Pars.window, Text_Size.scores);
    DrawFormattedText2('Score', 'win', Screen_Pars.window, 'sx', cpu_ax_start, 'sy', Text_Size.scores, ...
                       'xalign', 'right', 'yalign', 'bottom', 'baseColor', 252:255);
    DrawFormattedText2(num2str(Totals.cpu), 'win', Screen_Pars.window, 'sx', cpu_ax_start,...
                       'sy', Text_Size.scores*2, 'xalign', 'right', 'yalign', 'bottom', 'baseColor', 252:255);

    % See which entity to hide
    if Hide_Player
        Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], player_gray_rect);
        Screen('FrameRect', Screen_Pars.window, [0, 255, 0, 255], cpu_rect, 5);
    else
        Screen('FillRect', Screen_Pars.window, [50, 50, 50, 200], cpu_gray_rect);
        Screen('FrameRect', Screen_Pars.window, [0, 255, 0, 255], player_rect, 5);
    end
end