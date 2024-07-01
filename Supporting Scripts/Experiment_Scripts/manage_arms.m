% function points = manage_arms(n_arms, change_probability, initialize)
function manage_arms(means)
    persistent means std_devs
    
    exist('means', 'var')
    % if initialize || isempty(means) || isempty(std_devs)
    %     % Initialize means and standard deviations for the arms
    %     means = floor(5 + (95-5) * rand(1, n_arms));   % Random means between 5 and 95
    %     std_devs = randi([1, 3], 1, n_arms);    % Random std devs chosen from 1, 2, or 3
    % 
    % else
    %     % Update the means of the arms based on the given probability
    %     for arm = 1:n_arms
    %         % 1 in 20 chance to change the mean of the arm
    %         if rand() < change_probability
    %             means(arm) = floor(5 + (95-5) * rand());
    %         end
    %     end
    % 
    % end
    % % Calculate points as the combination of the mean plus standard deviation
    % points = means + std_devs;
    % disp('Points for each arm:');
    % disp(points);
end
