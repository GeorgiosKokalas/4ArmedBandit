classdef CpuPlayerT3 < handle
    properties
        Behavior_Mode   % Mode of Behavior, each mode interprets and reacts to the player's actions differently 
        Choice_List     % The list of choices that we have   
        Next_Choice     % The choice that will be made next by the CPU
        Prev_Choice     % The most recent choice made by the current CPU
        Choice_Origins  % The start choice that we define
        Epsilon         % Sets the epsilon value for e-greedy algo
        Rewards         % Rewards received
        Counts          % Counts per choice
        Scores          % Scores from GetScores function
    end

    methods
        % Constructor, this sets up default mode
        function obj = CpuPlayerT3(behavior_mode, choice_list, next_choice, epsilon)
           
            if nargin < 1 || isempty(behavior_mode)
                behavior_mode = 1; 
            end
            if nargin < 2 || isempty(choice_list)
                choice_list = ['Y', 'B', 'A', 'X']; 
            end
            if nargin < 3 || isempty(next_choice)
                next_choice = choice_list(randi(length(choice_list)));
                % if behavior_mode == 1 || behavior_mode == 2
                %     next_choice = choice_list(randi(length(choice_list))); % Random choice for modes 1 and 2
                % else
                %     next_choice = obj.determineChoiceBasedOnScores(choice_list); % Determine choice based on scores for modes 3, 4, 5
                % end
            end
            if nargin < 4 || isempty(epsilon)
                epsilon = 0.4; 
            end
            obj.Behavior_Mode = behavior_mode;
            obj.Choice_List = choice_list;
            obj.Epsilon = epsilon;
            obj.Rewards = zeros(1, length(choice_list));
            obj.Counts = zeros(1, length(choice_list));
            obj.Next_Choice = next_choice;
            obj.Choice_Origins = next_choice;
            obj.Prev_Choice = next_choice;
            %obj.Scores = zeros(1, length(choice_list)); % Initialize scores         
        end
        
        % General method to change behavior
        function changeBehavior(obj, points) %, button_scores)
            obj.updateRewards(points); % Update the memory of the choices that we made
            %obj.Scores = button_scores; % Update scores based on passed button scores
            switch obj.Behavior_Mode  % Different functions based on behaviors
                case 1
                    obj.epsilonGreedyBehavior();
                case 2
                    obj.randomChoiceBehavior();
                % case 3
                %     obj.cheaterBehavior();
                % case 4
                %     obj.trickyBehavior();
                % case 5
                %     obj.scammyBehavior();
            end
        end        
        
        % Method that gives the CPU's response
        function choice = getResponse(obj,button_scores)
            switch obj.Behavior_Mode
                case 3
                    obj.cheaterBehavior(button_scores);
                case 4
                    obj.trickyBehavior(button_scores);
                case 5
                    obj.scammyBehavior(button_scores);
            end
            choice = obj.Next_Choice;
            obj.Prev_Choice = choice;
        end
        
        % Resets the CPU after every block
        function reset(obj)
            obj.Next_Choice = obj.Choice_Origins;
            obj.Rewards = zeros(1, length(obj.Choice_List));
            obj.Counts = zeros(1, length(obj.Choice_List));
            obj.Scores = zeros(1, length(obj.Choice_List)); % Reinitialize scores on reset
        end

    end
    
    % Methods used by the class internally
    methods (Access = private)
        % Method to update scores
        % function updateScores(obj, initialize)
        %     if nargin < 2
        %         initialize = false;
        %     end
        %     obj.Scores = GetScores(length(obj.Choice_List), .05, initialize);
        % end

        % Method that updates choices and rewards
        function updateRewards(obj, reward)
            choice_index = find(obj.Choice_List == obj.Prev_Choice, 1);
            if ~isempty(choice_index)
                obj.Rewards(choice_index) = obj.Rewards(choice_index) + reward;
                obj.Counts(choice_index) = obj.Counts(choice_index) + 1;
            end
        end

        % Determine choice based on scores for behaviors 3, 4, 5
        function choice = determineChoiceBasedOnScores(obj, choice_list)          
            switch obj.Behavior_Mode
                case 3 % cheaterBehavior
                    [~, best_index] = max(obj.Scores);
                    choice = choice_list(best_index);
                case 4 % trickyBehavior
                    [sorted_scores, sorted_indices] = sort(obj.Scores, 'descend');
                    best_score = sorted_scores(1); % best scores
                    second_best_score = sorted_scores(2); % second best score
                    if rand() < (1 - (best_score - second_best_score) / 25)
                        choice = choice_list(sorted_indices(2));
                    else
                        choice = choice_list(sorted_indices(1));
                    end
                case 5 % scammyBehavior
                    [~, worst_index] = min(obj.Scores);
                    choice = choice_list(worst_index);
                otherwise
                    error('Invalid behavior mode');
            end
        end

        %% Behavioral Functions
        % Epsilon Greedy Behavior
        function epsilonGreedyBehavior(obj)
            if rand() < obj.Epsilon
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
            else
                [~, best_index] = max(obj.Rewards ./ max(1, obj.Counts));
                obj.Next_Choice = obj.Choice_List(best_index);
            end
        end

        % Random Choice Behavior
        function randomChoiceBehavior(obj)
            obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
        end

        % The Cheater Behavior
        function cheaterBehavior(obj,button_scores)
            if rand() < .80
                [~, best_index] = max(button_scores);
                obj.Next_Choice = obj.Choice_List(best_index);
            else
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
            end
        end

        % Tricky Behavior
        function trickyBehavior(obj,button_scores)
            [sorted_scores, sorted_indices] = sort(button_scores, 'descend');
            best_score = sorted_scores(1); % best scores
            second_best_score = sorted_scores(2); %basically nescores   
            if rand() < 0.8
                if rand() < (1 - (best_score - second_best_score) / 25)
                    obj.Next_Choice = obj.Choice_List(sorted_indices(2));
                else
                    obj.Next_Choice = obj.Choice_List(sorted_indices(1));
                end
            else
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List))); % Random choice
            end

        end

        % Scammy Behavior
        function scammyBehavior(obj,button_scores)
            [~, sorted_indices] = sort(button_scores, 'ascend'); % Sort in ascending order to get the worst arms first
            if rand() < 0.80
                obj.Next_Choice = obj.Choice_List(sorted_indices(1)); % Choose the worst arm (index 1 after sorting in ascending order)
            else
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List))); % Random choice
            end
        end
    end
end
