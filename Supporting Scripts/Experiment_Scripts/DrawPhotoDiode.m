% Called by Experiment, Introduction, RunTrial and subscripts within those.
% Function that draws the photodiode and stores the time of the drawing for an event.        
% Input: 
%   - Pars   Parameters for the experiment
% Output: 
%   - time   When this happened
function time = DrawPhotoDiode(Pars)
    photodiode_rect = [0, Pars.screen.window_height*(5/6), ...
                        Pars.screen.window_width/11, Pars.screen.window_height];
    Screen('FillRect', Pars.screen.window, repmat(255, 1, 4), photodiode_rect);
    time = GetSecs();
end

% The function was initially meant to be larger, but I already
% incorporated it in the code, so I won't remove it to not break anything
% right now