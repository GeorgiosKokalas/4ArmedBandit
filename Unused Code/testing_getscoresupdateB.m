scores=[];
meanies=[];
for x = 1:100
    if x == 1
        [Button_Scores, change_log,f_means] = GetScoresUpdateB('YBAX', 5, 'A', true); % Initialize
    else
        % Draw new scores based on potentially updated means
        [Button_Scores, change_log, f_means] = GetScoresUpdateB('YBAX', 5, 'A'); % Update scores
    end
    disp(x);

    scores = [scores; Button_Scores]; % Collect scores
    meanies=[meanies;f_means];
end


