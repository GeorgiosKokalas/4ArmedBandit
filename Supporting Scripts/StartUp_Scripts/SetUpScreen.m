% Function called by: StartUp.m
% Role of function is to initialize PsychToolBox and the Screen for the experiment  
% Parameters: 
%   - Pars (A handle to the parameters)
% Return Values: None

function SetUpScreen(Pars)
    % Startup PsychToolBox 
    PsychDefaultSetup(2);

    % Set some settings to make sure PTB works fine.
    % Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);     % Gets rid of all Warnings
    Screen('Preference', 'Verbosity', 0);               % Gets rid of all PTB-related messages
    Screen('Preference', 'SkipSyncTests', 2);           % Synchronization is nice, but not skipping the tests can randomly crash the program 
    
    % Create the window in which we will operate
    [Pars.screen.window, ~] = Screen('OpenWindow', Pars.screen.screen, Pars.screen.color);

    %Set up text Preferences
    Screen('TextFont', Pars.screen.window, Pars.text.font.default);
end

