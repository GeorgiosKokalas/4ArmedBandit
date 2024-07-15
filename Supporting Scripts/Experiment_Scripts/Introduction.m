% Function called by Experiment.m
% Role of function is to introduce the participant to the experiment
% Parameters: 
%   - Pars      (A handle/pointer to the parameters)
% Return Values: None

function Introduction(Pars)
    % Load the colors
    load('colors.mat','color_list');
    event_holders = {};

    %% FIRST MESSAGE
    %% Create the Introductory Message for the Experiment     
    % Store the event
    event_holders{end+1} = parfeval(backgroundPool, @CreateEvent, 1, "intro1", GetSecs());
    
    Screen('TextSize', Pars.screen.window, 150);
    DrawFormattedText(Pars.screen.window, 'Multi Armed Bandit task', 'center', Pars.screen.center(2)-100, color_list.white);

    Screen('TextSize', Pars.screen.window, 100);
    DrawFormattedText(Pars.screen.window, 'Press any button to continue', 'center', Pars.screen.center(2)+150, color_list.white);
    Screen('Flip',Pars.screen.window);

    while ~KbCheck() && ~GetXBox().AnyButton; end
    WaitSecs(0.5);
    

    %% CHARACTER SELECTION
    % Set the appropriate text size for the intro
    Screen('TextSize', Pars.screen.window, Pars.text.size.intro);

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
    img_rects = img_rects .* [Pars.screen.window_width/8, Pars.screen.window_height/6,...
        Pars.screen.window_width/8, Pars.screen.window_height/6];

    % Create a map of all the images
    img_map = [1,2,3;4,5,6];
    sel_img = 1;

    break_greater_loop = false;
    while ~break_greater_loop 
        % Store the character selection event
        event_holders{end+1} = parfeval(backgroundPool, @CreateEvent, 1, "intro2", GetSecs());
    
        break_greater_loop = true;
        while true
            % Draw each image. Create a green border for the selected one
            for img_idx = 1:6
                DrawIcon(Pars, ['PlAv', num2str(img_idx), '.png'], img_rects(img_idx, :));
                if sel_img == img_idx
                    Screen('FrameRect', Pars.screen.window, color_list.green, img_rects(img_idx, :), 10);
                end
            end
            DrawFormattedText(Pars.screen.window, controls_message, 'center', Pars.text.size.intro, color_list.white);
            Screen('Flip', Pars.screen.window);

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
        Pars.avatars.player_avatar = sel_img;

        %% BUTTON SCHEME FAMILIARIZATION
        % Store the character selection event
        event_holders{end+1} = parfeval(backgroundPool, @CreateEvent, 1, "intro3", GetSecs());

        break_loop = false;
        controls_message = ['Familiarize yourself with the controls. \n',...
            'When ready press any other button'];

        in_fam_start = GetSecs();

        while ~break_loop
            % If it is early enough draw the photodiode

            pl_i = GetXBox();
            for button_idx = 1:length(Pars.target.button_names)
                color = Pars.target.colors(button_idx,:);
                if pl_i.(Pars.target.button_names(button_idx))
                    color = color/0.8;
                end

                Screen('FillOval',Pars.screen.window, color, Pars.target.rects(button_idx,:));
                
                if pl_i.(Pars.target.button_names(button_idx))
                    Screen('FrameOval',Pars.screen.window, repmat(255,1,4), Pars.target.ring_rects(button_idx,:), 10);
                end

                DrawIcon(Pars, ['Letter_', Pars.target.button_names(button_idx), '.png'],...
                    Pars.target.rects(button_idx,:));
            end

            Screen('TextSize', Pars.screen.window, Pars.text.size.intro3)
            DrawFormattedText2(controls_message, 'win', Pars.screen.window, 'sx', 'center', 'sy', 'top', ...
                               'xalign', 'center', 'baseColor', color_list.white);

            Screen('Flip',Pars.screen.window);
            
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

    % save all of the events
    for ev_idx = 1:length(event_holders)
        while ~strcmpi(event_holders{ev_idx}.State, 'finished'); disp(event_holders{ev_idx}.State); end
        Pars.NewEvent(fetchOutputs(event_holders{ev_idx}));
    end
end

