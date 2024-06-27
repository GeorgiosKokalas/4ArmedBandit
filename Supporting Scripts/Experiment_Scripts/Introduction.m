% Function called by Experiment.m
% Role of function is to introduce the participant to the experiment
% Parameters: 
%   - Screen_Pars (parameters for the screen used by the Program)
%   - Text_Pars  (parameters for the text)
% Return Values: None

function Introduction(Screen_Pars, Text_Pars, Targ_Pars)
    % Load the colors
    load('colors.mat','color_list');
    
    % Set the appropriate text size for the intro
    Screen('TextSize', Screen_Pars.window, Text_Pars.size.intro);

    % % Create the Introductory Message for the Experiment 
    greeting_message = ['Hello, welcome to the multi armed bandit task\n',...
                        'Your goal is to get as many points as you can by learning which buttons reward the most.\n',...
                        'You will be presented with four choices that are mapped to the four buttons of your controller.\n', ...
                        'One of these choices will be unavailable, and will be grayed out.\n',...
                        'NOTE: Points yielded by every button CAN change over time.\n\n\n',...
                        'You will be playing against a player at a time.\n', ...
                        'You can observe their choices and scores to maximize the outcome of yours.\n\n\n', ...
                        'Press any buttons to proceed.'];
                        
    DrawFormattedText(Screen_Pars.window, greeting_message, 'center', Screen_Pars.center(2)-200, color_list.white);

    % Update the Screen
    Screen('Flip',Screen_Pars.window);
    while ~KbCheck() && ~GetXBox().AnyButton; end
    WaitSecs(0.5);

    % Wait for player input
    % KbStrokeWait();
    break_loop = false;
    controls_message = ['Familiarize yourself with the controls. \n',...
                        'When ready press any other button'];                  

    while ~break_loop
        pl_i = GetXBox();
        for button_idx = 1:length(Targ_Pars.button_names)
            color = Targ_Pars.colors(button_idx,:);
            if pl_i.(Targ_Pars.button_names(button_idx))
                color = color/0.8;
            end

            Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));

            DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                Targ_Pars.rects(button_idx,:));
        end
        DrawFormattedText(Screen_Pars.window, controls_message, 0, Text_Pars.size.intro, color_list.white);

        Screen('Flip',Screen_Pars.window);

        break_loop = KbCheck() || (pl_i.AnyButton && ~pl_i.A && ~pl_i.B && ~pl_i.X && ~pl_i.Y);
        % break_loop = KbCheck() || pl_i.RB || pl_i.LB || pl_i.RT > 0.5 || pl_i.LT > 0.5 || ...
        %              pl_i.DPadDown || pl_i.DPadLeft || pl_i.DPadUp || pl_i.DPadRight || ...
        %              ;
    end
    WaitSecs(0.5);
end

