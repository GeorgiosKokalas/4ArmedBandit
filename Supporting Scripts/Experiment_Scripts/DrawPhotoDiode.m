% Function that draws the photodiode and stores the time of the drawing for an event.    
% Called by Experiment, Introduction, RunTrial and subscripts within those.    
% Input: Screen_Pars    Parameters for the screen
% Output: time          When this happened
function time = DrawPhotoDiode(Screen_Pars)
    photodiode_rect = [0, Screen_Pars.window_height*(8/9), ...
                        Screen_Pars.window_width/8, Screen_Pars.window_height];
    Screen('FillRect', Screen_Pars.window, repmat(255, 1, 4), photodiode_rect);
    time = GetSecs();
end

% The function was initially meant to be larger, but I already
% incorporated it in the code, so I won't remove it to not break anything
% right now