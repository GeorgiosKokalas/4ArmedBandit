% Function called by Experiment.m
% Role of function is to introduce the participant to the experiment
% Parameters: 
%   - Screen_Pars (parameters for the screen used by the Program)
%   - Text_Pars  (parameters for the text)
%   - Targ_Pars  (parameters for the targets)
% Return Values: 
%   - player_avatar

function [player_avatar] = Introduction(Screen_Pars, Text_Pars, Targ_Pars)
    % Load the colors
    load('colors.mat','color_list');
    
    %% FIRST MESSAGE
    %% Create the Introductory Message for the Experiment     
    Screen('TextSize', Screen_Pars.window, 150);
    DrawFormattedText(Screen_Pars.window, 'Multi Armed Bandit task', 'center', Screen_Pars.center(2)-100, color_list.white);

    Screen('TextSize', Screen_Pars.window, 100);
    DrawFormattedText(Screen_Pars.window, 'Press any button to continue', 'center', Screen_Pars.center(2)+150, color_list.white);
    Screen('Flip',Screen_Pars.window);

    while ~KbCheck() && ~GetXBox().AnyButton; end
    WaitSecs(0.5);
    

    %% CHARACTER SELECTION
    % Set the appropriate text size for the intro
    Screen('TextSize', Screen_Pars.window, Text_Pars.size.intro);

    contd_in = false;   % Continued input check
    controls_message = ['Please select your avatar.\n',...
                        'Use the Dpad or any of the Joysticks to navigate\n',...
                        'Press A, B, X or Y to make your selection'];

    % Create a matrix for all 6 image rects
    rect_base = [1, 1, 3, 3];
    img_rects = rect_base;
    % Create the first row
    for i = 1:2
        img_rects = [img_rects; img_rects(end, :) + [2, 0, 2, 0]];
    end
    img_rects = [img_rects; img_rects+ [0,2,0,2]]; % Create the second row

    % Adjust the rects for the screen size
    img_rects = img_rects .* [Screen_Pars.window_width/8, Screen_Pars.window_height/6,...
        Screen_Pars.window_width/8, Screen_Pars.window_height/6];

    % Create a map of all the images
    img_map = [1,2,3;4,5,6];
    sel_img = 1;

    break_greater_loop = false;
    while ~break_greater_loop 
        break_greater_loop = true;
        while true
            % Draw each image. Create a green border for the selected one
            for img_idx = 1:6
                DrawIcon(Screen_Pars.window, ['PlAv', num2str(img_idx), '.png'], img_rects(img_idx, :));
                if sel_img == img_idx
                    Screen('FrameRect', Screen_Pars.window, color_list.green, img_rects(img_idx, :), 10);
                end
            end
            DrawFormattedText(Screen_Pars.window, controls_message, 'center', Text_Pars.size.intro, color_list.white);
            Screen('Flip', Screen_Pars.window);

            % Wait for the XBox Controller signal
            pl_i = GetXBox();

            % Prevent player from continuously giving input
            contd_in_cond = ~pl_i.AnyButton && abs(pl_i.JoystickRX) < 0.5 && abs(pl_i.JoystickRY) < 0.5 &&...
                abs(pl_i.JoystickLX) < 0.5 && abs(pl_i.JoystickLY) < 0.5;
            if contd_in_cond; contd_in = false; end
            if contd_in; continue; end

            % Navigate the Images using the DPad
            try
                [new_img_y, new_img_x] = find(img_map == sel_img);

                % Observe player movement from joysticks and DPad
                down_cond = pl_i.DPadDown || (pl_i.JoystickRY > 0.5 && abs(pl_i.JoystickRX) < 0.5) ||...
                    (pl_i.JoystickLY > 0.5 && abs(pl_i.JoystickLX) < 0.5);
                up_cond = pl_i.DPadUp || (pl_i.JoystickRY < -0.5 && abs(pl_i.JoystickRX) < 0.5) ||...
                    (pl_i.JoystickLY < -0.5 && abs(pl_i.JoystickLX) < 0.5);
                right_cond = pl_i.DPadRight || (pl_i.JoystickRX > 0.5 && abs(pl_i.JoystickRY) < 0.5) ||...
                    (pl_i.JoystickLX > 0.5 && abs(pl_i.JoystickLY) < 0.5);
                left_cond = pl_i.DPadLeft || (pl_i.JoystickRX < -0.5 && abs(pl_i.JoystickRY) < 0.5) ||...
                    (pl_i.JoystickLX < -0.5 && abs(pl_i.JoystickLY) < 0.5);
                % Move the player based on their input
                if     down_cond;  new_img_y = new_img_y + 1;
                elseif up_cond;    new_img_y = new_img_y - 1;
                elseif right_cond; new_img_x = new_img_x + 1;
                elseif left_cond;  new_img_x = new_img_x - 1;
                end
                sel_img = img_map(new_img_y, new_img_x);

                % Store the fact that we already moved
                if up_cond || down_cond || left_cond || right_cond
                    contd_in = true;
                end

                % DEBUG
                % disp([new_img_x, new_img_y]);
                % disp(sel_img);
            catch
            end

            % Check for selection buttons
            if pl_i.A || pl_i.B || pl_i.X || pl_i.Y; break; end
        end
        player_avatar = sel_img;

        %% BUTTON SCHEME FAMILIARIZATION
        % Wait for player input
        % KbStrokeWait();
        break_loop = false;
        controls_message = ['Familiarize yourself with the controls. \n',...
            'When ready press any other button'];

        in_fam_start = GetSecs();

        while ~break_loop
            % If it is early enough draw the photodiode

            pl_i = GetXBox();
            for button_idx = 1:length(Targ_Pars.button_names)
                color = Targ_Pars.colors(button_idx,:);
                if pl_i.(Targ_Pars.button_names(button_idx))
                    color = color/0.8;
                end

                Screen('FillOval',Screen_Pars.window, color, Targ_Pars.rects(button_idx,:));
                
                if pl_i.(Targ_Pars.button_names(button_idx))
                    Screen('FrameOval',Screen_Pars.window, repmat(255,1,4), Targ_Pars.ring_rects(button_idx,:), 10);
                end

                DrawIcon(Screen_Pars.window, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                    Targ_Pars.rects(button_idx,:));
            end

            Screen('TextSize', Screen_Pars.window, Text_Pars.size.intro3)
            DrawFormattedText2(controls_message, 'win', Screen_Pars.window, 'sx', 'center', 'sy', 'top', ...
                               'xalign', 'center', 'baseColor', color_list.white);

            Screen('Flip',Screen_Pars.window);
            
            [key_pressed, ~, key_code] = KbCheck();
            break_loop = key_pressed || (pl_i.AnyButton && ~pl_i.A && ~pl_i.B && ~pl_i.X && ~pl_i.Y);
            if pl_i.JoystickRThumb || pl_i.JoystickLThumb || key_code(KbName('r')) == 1
                break_greater_loop = false;
            end
            % break_loop = KbCheck() || pl_i.RB || pl_i.LB || pl_i.RT > 0.5 || pl_i.LT > 0.5 || ...
            %              pl_i.DPadDown || pl_i.DPadLeft || pl_i.DPadUp || pl_i.DPadRight || ...
            %              ;
        end
        WaitSecs(0.5);
    end
end

