% Function called by: Experiment.m
% Let the player know that the CPU will be changing.
% Parameters: screen_pars (the screen_parameters)
% Return Values: None

function Intermission(screen_pars)
    load('colors.mat','color_list');

    while ~KbCheck() && ~GetXBox().AnyButton
       % Draw out the messages
       message = 'You will now be playing with a different player.';
       message2 = 'Press any button to continue';
       DrawFormattedText(screen_pars.window, message, 'center', screen_pars.center(2)-50, color_list.white);
       DrawFormattedText(screen_pars.window, message2, 'center', 'center', color_list.white);

       % Update the Screen
       Screen('Flip', screen_pars.window);
   end
   WaitSecs(0.5);
end