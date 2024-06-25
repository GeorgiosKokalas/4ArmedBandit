% Function called by: Experiment.m
% Role of function is to debrief the participant after finishing
% Parameters: 
%   - screen (screen parameters)
%   - total _score (total score)
% Return Values: None

function Debrief(screen, score_totals, types)
    load('colors.mat','color_list');
    
    score_total_msg = '';
    for typeIdx = 1:length(types)
        score_total_msg = [score_total_msg, char(types(typeIdx)), ' Total Score: ', num2str(score_totals(typeIdx)), '\n'];
    end
    DrawFormattedText(screen.window, score_total_msg, 'center', screen.window_height/2 - 120, color_list.white);
    
    message = 'Thank you for participating!';
    DrawFormattedText(screen.window, message, 'center', 'center', color_list.white);

    Screen('Flip', screen.window);
end

