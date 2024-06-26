% Function called by: InsertParams.m
% Role of function is to validate all user-inserted parameters
% Parameters: in_pars (struct that contains all inserted parameters)
% Return Values: in_pars (in_pars after validation)
% Function that is aimed to validate all inserted parameters by the user. 
%   If values are invalid they are updated. More parameters are also added.

function in_pars = ValidateInsertParams(in_pars, Patient_Name)
    load('colors.mat','color_list');
    
    %in_pars.screen extra variables (dependent on user-defined variables)
    in_pars.screen.custom_screen_ = false;         % dependent on start_point, height and width
    in_pars.screen.window = -1;                    % will be used to hold the window (-1 is a placeholder)
    in_pars.screen.center = [0,0];                 % will be used to represent the center of the window
    in_pars.screen.screen_width = 0;               % the width of the screen in which the window will be housed 
    in_pars.screen.screen_height = 0;              % the height of the screen in which the window will be housed 
    in_pars.screen.window_dims = [0,0];            % the dimensions of the window (combines width and height)    

    % in_pars.screen - VALUE EVALUATION
    % Evaluating color
    if ~isrgba(in_pars.screen.color)
        disp("Inoperable value provided for in_pars.screen.color. Applying default...");
        in_pars.screen.color = color_list.grey;
    end
    
    % Evaluating screen (must be within the acceptable range of the available Screens
    if ~isnat(in_pars.screen.screen) || in_pars.screen.screen > max(Screen('Screens'))
        disp("Inoperable value provided for in_pars.screen.screen. Applying default...");
        in_pars.screen.screen = max(Screen('Screens'));
    end

    % change the value of screen_width and screen_height based on the screen
    [in_pars.screen.screen_width, in_pars.screen.screen_height] = Screen('WindowSize', in_pars.screen.screen);
    
    % change the value of custom_screen_ based on the value of start_point 
    dims = [in_pars.screen.screen_width, in_pars.screen.screen_height];
    if ~isloc(in_pars.screen.start_point, dims)
        disp("Inoperable value provided for in_pars.screen.start_point. Applying default...");
        in_pars.screen.start_point = [0, 0];
    end
    
    % change the value of custom_screen_ based on the value of height and width
    make_custom_screen = isnat(in_pars.screen.window_height) && ...          & too long for 1 line 
        isnat(in_pars.screen.window_width) && ...
        in_pars.screen.window_height <= in_pars.screen.screen_height && ...
        in_pars.screen.window_width <= in_pars.screen.screen_width;
    if make_custom_screen   
        disp("Custom Valus provided for Width and Length. Abandoning FullScreen Mode...");
        in_pars.screen.custom_screen_ = true;
    else 
        disp("Assuming FullScreen Mode.");
        [in_pars.screen.window_width, in_pars.screen.window_height] = Screen('WindowSize', in_pars.screen.screen);
    end

    % change the value of in_pars.screen.center, based on screen width and height
    in_pars.screen.center = [in_pars.screen.window_width / 2, in_pars.screen.window_height / 2];

    % change the value of in_pars.screen.window_dims
    in_pars.screen.window_dims = [in_pars.screen.window_width, in_pars.screen.window_height];


    %in_pars.text- VALUE EVALUATION
    % Get all the size parameters
    all_sizes = fieldnames(in_pars.text.size);
    for size_idx = 1:length(all_sizes)
        if ~isnat(in_pars.text.size.(all_sizes{size_idx}))
            disp(sprinf("Inoperable value provided for in_pars.target.size.%s. Applying default...",all_sizes{size_idx}));
            in_pars.text.size.(all_sizes{size_idx}) = 40;
        end
    end


    %in_pars.trial - VALUE EVALUATION
    % Evaluating show_intro
    if ~isscalar(in_pars.trial.show_intro) || ~islogical(in_pars.trial.show_intro)
        disp("Inoperable value provided for in_pars.trial.show_intro. Applying default...");
        in_pars.trial.show_intro = 20;
    end

    % Evaluating duration_s
    if ~isnat(in_pars.trial.duration_s)
        disp("Inoperable value provided for in_pars.trial.duration_s. Applying default...");
        in_pars.trial.duration_s = 20;
    end

    % Evaluating cpu_wait_s
    if ~isnumlist(in_pars.trial.cpu_wait_s, "whole") || in_pars.trial.cpu_wait_s(1) > in_pars.trial.cpu_wait_s(2)
        disp("Inoperable value provided for in_pars.trial.cpu_wait_s. Applying default...");
        in_pars.trial.cpu_wait_s = [2,4];
    end

    % Evaluating num
    if ~isnat(in_pars.trial.num)
        disp("Inoperable value provided for in_pars.trial.num. Applying default...");
        in_pars.trial.num = 0;
    end

    % Extra variables for in_pars.trial.cpu_wait_s
    in_pars.trial.cpu_wait_dur = in_pars.trial.cpu_wait_s(2) - in_pars.trial.cpu_wait_s(1);


    %in_pars.target - VALUE EVALUATION
    button_names = ['Y', 'B', 'A', 'X'];

    % Evaluating target.radius_percent
    if ~isnat(in_pars.target.radius_percent) || in_pars.target.radius_percent > 100
        disp("Inoperable value provided for in_pars.trial.cpu_wait_s. Applying default...")
        in_pars.target.radius_percent = 100;
    end
 

    %Evaluating target.colors
    tch = height(in_pars.target.colors);
    for idx = 1:tch
        if ~isrgba(in_pars.target.colors(idx, :)) || tch ~= 4
            disp("Inoperable value provided for in_pars.target.colors. Applying default...")
            in_pars.target.colors = [color_list.yellow * 0.8; color_list.red * 0.8;...
                                     color_list.green * 0.8; color_list.blue * 0.8];
            break;
        end
    end

    % Evaluating target.scores
    if ~iswhole(in_pars.target.score_change_rng) || in_pars.target.score_change_rng > 100
        disp("Inoperable value provided for in_pars.target.score_change_rng. Applying default...");
        in_pars.target.score_change_rng = 30;
    end   

    % extra variables for in_pars.target
    w_width = in_pars.screen.window_width;
    w_height = in_pars.screen.window_height;
    shorter_dist = min([sqrt( (w_width/4)^2 + (w_height/4)^2 ), w_width/2, w_height/ 2]);
    in_pars.target.radius = max(20, (shorter_dist/2)*(in_pars.target.radius_percent/100));

    x = in_pars.screen.window_width;
    y = in_pars.screen.window_height;
    r = in_pars.target.radius;
    coords = [x/2, y/4; 3*x/4, y/2; x/2, 3*y/4; x/4, y/2];
    rects = zeros(4,4);
    for idx = 1:4
        rects(idx,:) = [coords(idx, 1)-r, coords(idx, 2)-r, coords(idx, 1)+r, coords(idx, 2)+r];
    end
    in_pars.target.button_names = button_names;
    in_pars.target.coords = coords;
    in_pars.target.rects = rects;



    % in_pars.disbtn (disable buttons) - VALUE EVALUATION
    % Evaluating disbtn.player
    dpl = length(in_pars.disbtn.player);
    change_pb = false;
    if ~ischar(in_pars.disbtn.player)
        if ~isstring(in_pars.disbtn.player); change_pb = true;
        else; in_pars.disbtn.player = char(in_pars.disbtn.player);
        end
    end
    for idx = 1:dpl
        if ~contains(lower(button_names), lower(in_pars.disbtn.player(idx)))
            change_pb = true;
            break;
        end
    end
    if change_pb || ~isvector(in_pars.disbtn.player)
        disp("Inoperable value provided for in_pars.disbtn.player. Applying default...");
        in_pars.disbtn.player = 'A';
    end

    % Evaluating disbtn.cpu
    dcl = length(in_pars.disbtn.cpu);
    change_cb = false;
    if ~ischar(in_pars.disbtn.cpu)
        if ~isstring(in_pars.disbtn.cpu); change_cb = true;
        else; in_pars.disbtn.cpu = char(in_pars.disbtn.cpu);
        end
    end
    for idx = 1:dcl
        if ~contains(lower(button_names), lower(in_pars.disbtn.cpu(idx)))
            change_cb = true;
            break;
        end
    end
    if change_cb || ~isvector(in_pars.disbtn.cpu) || dcl ~= dpl
        disp("Inoperable value provided for in_pars.disbtn.cpu. Applying default...");
        in_pars.disbtn.cpu = repmat('Y', 1, dpl);
    end

    % CREATING OUTPUT DIRECTORY 
    in_pars.output_dir = fullfile(pwd(),'Output', [Patient_Name, '_' ,datestr(datetime('now'), 'yyyymmdd-HHMM')]);
end




% Custom functions to make the code above more readable
%Checks if a value is a single number
function result = isnum(input)
    result = isscalar(input) && isnumeric(input);
end


%Checks if a value is a whole number (including 0 and positive integers)
function result = iswhole(input)
    % I define naturals as any number equal to or above 0
    result = isnum(input) && input >= 0 && round(input) == input;
end


%Checks if a value is a natural number (integers > 0)
function result = isnat(input)
    %Check if this is a number above 0
    result = isnum(input) && input > 0 && round(input) == input;
end

% Check if a value is composed of numbers
function result = isnumlist(input, Option)
    check_option = exist("Option", "var");
    if check_option
        check_option = check_option && (...
                        strcmpi(char(Option), 'num') || ...
                        strcmpi(char(Option), 'whole') || ...
                        strcmpi(char(Option), 'nat'));
    end
    if ~check_option; Option = 'num'; end

    result = isvector(input);
    try
        for idx = 1:length(input)
            if strcmpi(Option, 'num')
                result = result && isnum(input(idx));
            elseif strcmpi(Option, 'nat')
                result = result && isnat(input(idx));
            elseif strcmpi(Option, 'whole')
                result = result && iswhole(input(idx));
            else
                result = false;
            end
        end
    catch ME
        result = false;
    end
end

% Checks if a value is a vector pretaining to a specific color
function result = isrgba(input)
    % RGBA values are represented as vectors of 4 elements (numbers)
    result = isvector(input) && numel(input) == 4 && isnumlist(input, 'whole');

    % If this is a vector, check if every element is a whole number no greater than 255 
    if result
        for idx = 1:numel(input)
            if input(idx) > 255; result = false; end
        end
    end
end


function result = isloc(input, Dimensions)
    % Locations are vectors of x and y axes
    result = isvector(input) && numel(input) == 2 && isnumlist(input, 'whole');

    %Check if the values of the x and y axis are within the acceptable value for our screen  
    % [screen_width, screen_height] = Screen('WindowSize', Screen_Number);
    if result
        result = input(1)<Dimensions(1) && input(2)<Dimensions(2);
    end
end