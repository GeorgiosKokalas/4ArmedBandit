classdef CpuPlayer < handle
    properties
        Behavior_Mode   % Mode of Behavior, each mode interprets and reacts to the player's actions differently 
        Score_Mode      % How the CPU's scores will be interacting with the player's scores
        Name            % The name presented to the participant to represent the current cpu player
        Choice_List     % The list of choices that we have   
        Choice_List_OG  % A record of the choice list originally
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
        function obj = CpuPlayer(behavior_mode, score_mode, name, choice_list, next_choice, epsilon)
            % PRELIMINARY CHECKS
            is_valid_mode = false;

            % Check for the behavior mode
            if ~exist("behavior_mode", "var") || isempty(behavior_mode)
                behavior_mode = 1; 
            end

            if ~exist("name", "var") || isempty(name)
                name = 'Joshua';
            else
                name = char(name);
            end
                

            % Check for the score mode
            if exist("score_mode", "var")
                avaliable_modes = ["indifferent", "competitive", "cooperative"];
                for idx = 1:length(avaliable_modes)
                    if strcmpi(score_mode, avaliable_modes(idx))
                        is_valid_mode = true;
                    end 
                end
            end
            if ~is_valid_mode; score_mode = "Indifferent"; end
            
            % Check for the choice list
            if ~exist("choice_list", "var") || isempty(choice_list)
                choice_list = ['Y', 'B', 'A', 'X']; 
            end

            % Check for the next choice
            if ~exist("next_choice", "var") || isempty(next_choice)
                next_choice = choice_list(randi(length(choice_list)));
            end

            % Check for epsilon
            if ~exist("epsilon", "var")|| isempty(epsilon)
                epsilon = 0.4; 
            end

            % Assign the arguments to the class variables.
            obj.Behavior_Mode = behavior_mode;
            obj.Score_Mode = score_mode;
            obj.Name = name;
            obj.Choice_List = choice_list;
            obj.Choice_List_OG = choice_list;
            obj.Epsilon = epsilon;
            obj.Rewards = zeros(1, length(choice_list));
            obj.Counts = zeros(1, length(choice_list));
            obj.Next_Choice = next_choice;
            obj.Choice_Origins = next_choice;
            obj.Prev_Choice = next_choice;    
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
        function choice = getResponse(obj,Button_Scores)
            switch obj.Behavior_Mode
                case 3
                    obj.cheaterBehavior(Button_Scores);
                case 4
                    obj.trickyBehavior(Button_Scores);
                case 5
                    obj.trickyBehavior(Button_Scores); %changed from cheaterBehavior
            end
            choice = obj.Next_Choice;
            obj.Prev_Choice = choice;
        end
        
        % Resets the CPU after every block
        function reset(obj)
            obj.Next_Choice = obj.Choice_Origins;
            obj.Rewards = zeros(1, length(obj.Choice_List));
            obj.Counts = zeros(1, length(obj.Choice_List));
            obj.Scores = zeros(1, length(obj.Choice_List));
            obj.Choice_List = obj.Choice_List_OG;
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
        function updateRewards(obj, Reward)
            choice_index = find(obj.Choice_List == obj.Prev_Choice, 1);
            if ~isempty(choice_index)
                obj.Rewards(choice_index) = obj.Rewards(choice_index) + Reward;
                obj.Counts(choice_index) = obj.Counts(choice_index) + 1;
            end
        end

        % Determine choice based on scores for behaviors 3, 4, 5
        function choice = determineChoiceBasedOnScores(obj, Choice_List)          
            switch obj.Behavior_Mode
                case 3 % cheaterBehavior
                    [~, best_index] = max(obj.Scores);
                    choice = Choice_List(best_index);
                case 4 % trickyBehavior
                    [sorted_scores, sorted_indices] = sort(obj.Scores, 'descend');
                    best_score = sorted_scores(1); % best scores
                    second_best_score = sorted_scores(2); % second best score
                    if rand() < (1 - (best_score - second_best_score) / 25)
                        choice = Choice_List(sorted_indices(2));
                    else
                        choice = Choice_List(sorted_indices(1));
                    end
                case 5 % scammyBehavior
                    [~, worst_index] = min(obj.Scores);
                    choice = Choice_List(worst_index);
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
        function cheaterBehavior(obj, Button_Scores)
            if rand() < .55
                [~, best_index] = max(Button_Scores);
                obj.Next_Choice = obj.Choice_List(best_index);
            else
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
            end
        end

        % Tricky Behavior
        function trickyBehavior(obj,Button_Scores)
            [~, sorted_indices] = sort(Button_Scores, 'descend');

            % Probability threshold
            top_scores_prob = 0.55;
            
            % Determine the next choice based on the defined probabilities
            if rand() < top_scores_prob
                % Choose from the top two scores
                if rand() < 0.5
                    obj.Next_Choice = obj.Choice_List(sorted_indices(1)); % Choose the highest score
                else
                    obj.Next_Choice = obj.Choice_List(sorted_indices(2)); % Choose the second highest score
                end
            else
                % Choose from the bottom two scores
                if rand() < 0.5
                    obj.Next_Choice = obj.Choice_List(sorted_indices(3)); % Choose the third highest score
                else
                    obj.Next_Choice = obj.Choice_List(sorted_indices(4)); % Choose the lowest score
                end
            end
        end

        % Scammy Behavior
        function scammyBehavior(obj,Button_Scores)
            [~, sorted_indices] = sort(Button_Scores, 'ascend'); % Sort in ascending order to get the worst arms first
            if rand() < 0.80
                obj.Next_Choice = obj.Choice_List(sorted_indices(1)); % Choose the worst arm (index 1 after sorting in ascending order)
            else
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List))); % Random choice
            end
        end
    end
end
