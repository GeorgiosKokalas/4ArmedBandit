% Function called by: StartUp.m
% Role of function is to initialize PsychToolBox and the Screen for the experiment  
% Parameters: screen_pars (parameters for the screen)
% Return Values: screen_pars (updated parameters for the screen)

function screen_pars = SetUpScreen(screen_pars)
    % Startup PsychToolBox 
    PsychDefaultSetup(2);

    % Set some settings to make sure PTB works fine.
    % Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);     % Gets rid of all Warnings
    Screen('Preference', 'Verbosity', 0);               % Gets rid of all PTB-related messages
    Screen('Preference', 'SkipSyncTests', 2);           % Synchronization is nice, but not skipping the tests can randomly crash the program 
    
    % Create the window in which we will operate
    [screen_pars.window, i ] = Screen('OpenWindow', screen_pars.screen, screen_pars.color, ...
        [screen_pars.start_point, screen_pars.window_dims]);

    %Set up text Preferences
    Screen('TextFont', screen_pars.window, screen_pars.default_text_font);
    % Screen('TextSize', screen_pars.window, screen_pars.default_text_size);
end

