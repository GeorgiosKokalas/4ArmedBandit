% Function called by: StartUp.m
% Role of function is to generate all user-inserted parameters 
% This means that any value that can be safely changed by the user should be done here. 
% Parameters: 
%   - Patient_Name (The name of the patient)
%   - Emu_Num      (The number of the experiment in the EMU)
% Return Values: 
%   - in_pars (struct that contains all inserted parameters)

function in_pars = InsertParams(Patient_Name)
    in_pars = ParameterClass(Patient_Name);
    load('colors.mat','color_list');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % User defined variables below %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % in_pars.screen - Determines the color of the screen the participant will be playing in 
    in_pars.screen.color = color_list.black;      % RGBA - Determines the color of the screen
    
    % Optional parameters, best left untouched.
    in_pars.screen.screen = max(Screen('Screens')); % Select the Screen you want to use.
    in_pars.screen.start_point = [0, 0];            % Vector - Determines the upmost left corner of the screen. [0,0] is the default 
    in_pars.screen.window_height = 0;               % Integer - Determines the Height of the window. 0 will make the program FullScreen 
    in_pars.screen.window_width = 0;                % Integer - Determines the Width of the window. 0 will make the program FullScreen
    
    % Text parameters
    % Text Font Parameters - Determine the font used in the experiment
    in_pars.text.font.default = 'Helvetica';    % String - Determines the type of font used in the experiment

    % Text Size parameters - Determine the size of text in given situations
    in_pars.text.size.default = 40;         % Integer - Determines the default text size
    in_pars.text.size.intro = 45;           % Integer - Determines the text size during the Introduction
    in_pars.text.size.intro3 = 70;          % Integer - Determines the text size during the 3rd part of the Introduction
    % in_pars.text.size.score_count = 50;     % POSSIBLY UNUSED   
    in_pars.text.size.button_score = 220;   % Integer - Determines the size of the score displayed on each button
    in_pars.text.size.title = 25;           % Integer - Determines the size of the title below each avatar
    in_pars.text.size.scores = 45;          % Integer - Determines the size of the total scores displayed next to the avatars
    in_pars.text.size.turn_order = 80;      % Integer - Determines the size of the text displaying the turn order
    in_pars.text.size.score_mode = 80;      % Integer - Determines the size of the text showing the score mode up top
    in_pars.text.size.score_totals = 100;   % Integer - Determines the variable Totals value displayed on the bottom

    % Trial Parameters
    in_pars.trial.show_intro = true;        % Logical - Determines whether or not the introduction will be shown
    % in_pars.trial.duration_s = 20;          % POSSIBLY UNUSED
    in_pars.trial.cpu_wait_s = [2, 4];      % Vector of 2 positives - Range of cpu waiting times to simulate decision making
    in_pars.trial.num = 50;                 % Integer - Determines the number of trials per block
    in_pars.trial.photodiode_dur_s = 0.5;   % Positive number - determines how long the photodiode will be shown for

    in_pars.target.radius_percent = 95;                    % Positive integer - The percentage of size compared to their possible max
    in_pars.target.colors = [color_list.yellow * 0.8;...
                             color_list.red    * 0.8;...
                             color_list.green  * 0.8;...
                             color_list.blue   * 0.8];  % 4 RGBA values for the target
    in_pars.target.score_change_rng = 5;    % Integer - How likely each score is to change
    
    in_pars.disbtn.player = 'A';   % Character(s) - Which button(s) will be disabled for the player
    in_pars.disbtn.cpu = '';       % Character(s) - Which button(s) will be disabled for the cpu 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End of Settings %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ValidateInsertParams(in_pars);
end

