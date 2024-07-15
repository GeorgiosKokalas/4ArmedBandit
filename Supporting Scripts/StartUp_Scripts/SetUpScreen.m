% Function called by: StartUp.m
% Role of function is to initialize PsychToolBox and the Screen for the experiment  
% Parameters: 
%   - Screen_Pars (parameters for the screen)
%   - Text_Font   (parameters for the text font)
% Return Values: 
%   - Screen_Pars (updated parameters for the screen)

function Screen_Pars = SetUpScreen(Screen_Pars, Text_Font)
    % Startup PsychToolBox 
    PsychDefaultSetup(2);

    % Set some settings to make sure PTB works fine.
    % Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);     % Gets rid of all Warnings
    Screen('Preference', 'Verbosity', 0);               % Gets rid of all PTB-related messages
    Screen('Preference', 'SkipSyncTests', 2);           % Synchronization is nice, but not skipping the tests can randomly crash the program 
    
    % Create the window in which we will operate
    [Screen_Pars.window, i ] = Screen('OpenWindow', Screen_Pars.screen, Screen_Pars.color, ...
        [Screen_Pars.start_point, Screen_Pars.window_dims]);

    %Set up text Preferences
    Screen('TextFont', Screen_Pars.window, Text_Font.default);
end

