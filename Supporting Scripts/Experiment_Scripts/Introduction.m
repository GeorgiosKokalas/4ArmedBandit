% Function called by Experiment.m
% Role of function is to introduce the participant to the experiment
% Parameters: 
%   - screen_pars (parameters for the screen used by the Program)
%   - text_pars  (parameters for the text)
% Return Values: None

function Introduction(screen_pars, text_pars)
    % Load the colors
    load('colors.mat','color_list');
    
    % Set the appropriate text size for the intro
    Screen('TextSize', screen_pars.window, text_pars.size.intro);

    % % Create the Introductory Message for the Experiment 
    greeting_message = ['Hello.'];
    DrawFormattedText(screen_pars.window, greeting_message, 'center', screen_pars.center(2)-150, color_list.white);

    % Update the Screen
    Screen('Flip',screen_pars.window);

    % Wait for player input
    % KbStrokeWait();
    while ~KbCheck() && ~GetXBox().AnyButton; end
    WaitSecs(0.5);
end

