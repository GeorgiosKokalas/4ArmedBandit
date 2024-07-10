% A class that defines a CPU player.
% It can currently:
%   - Adapt its behavior (changeBehavior)
%   - Respond to a choice (getResponse)
%   - Reset (reset)

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
        Behaviors       % A struct of behavior functions
        Scores          % Scores from GetScores function
    end

    methods
        % Constructor, this sets up default mode
        function obj = CpuPlayerT3(behavior_mode, choice_list, next_choice, epsilon)
            if ~exist("behavior_mode", "var") || isempty(behavior_mode)
                behavior_mode = 1; 
            end
            if ~exist("choice_list", "var") || isempty(choice_list)
                choice_list = ['A', 'B', 'X', 'Y']; 
            end
            if ~exist("next_choice", "var") || isempty(next_choice)
                next_choice = choice_list(randi(length(choice_list))); 
            end
            if ~exist("epsilon", "var") || isempty(epsilon)
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
            obj.updateScores(true); % Initialize scores
        end
        
        % General method to change behavior
        function changeBehavior(obj, points)
            obj.updateRewards(points); % Update the memory of the choices that we made
            obj.updateScores(false); % Update scores on behavior change
            switch obj.Behavior_Mode  % Different functions based on behaviors
                case 1
                    obj.epsilonGreedyBehavior();
                case 2
                    obj.randomChoiceBehavior();
                case 3
                    obj.cheaterBehavior();
                case 4
                    obj.trickyBehavior();
                case 5
                    obj.scammyBehavior();
                otherwise
                    error('Unknown behavior mode');
            end
        end        
        
        % Method that gives the CPU's response
        function choice = getResponse(obj)
            choice = obj.Next_Choice;
            obj.Prev_Choice = choice;
        end
        
        % Resets the CPU after every block
        function reset(obj)
            obj.Next_Choice = obj.Choice_Origins;
            obj.Rewards = zeros(1, length(obj.Choice_List));
            obj.Counts = zeros(1, length(obj.Choice_List));
            obj.updateScores(true); % Reinitialize scores on reset
        end

    end
    
    % Methods used by the class internally
    methods (Access = private)
        % Method to update scores
        function updateScores(obj, initialize)
            if nargin < 2
                initialize = false;
            end
            obj.Scores = GetScores(length(obj.Choice_List), .05, initialize);
        end

        % Method that updates choices and rewards
        function updateRewards(obj, reward)
            choice_index = find(obj.Choice_List == obj.Prev_Choice, 1);
            if ~isempty(choice_index)
                obj.Rewards(choice_index) = obj.Rewards(choice_index) + reward;
                obj.Counts(choice_index) = obj.Counts(choice_index) + 1;
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
        function cheaterBehavior(obj)
            if rand() < 0.60
                [~, best_index] = max(obj.Scores);
                obj.Next_Choice = obj.Choice_List(best_index);
            else
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
            end
        end

        % Tricky Behavior
        function trickyBehavior(obj)
            [sorted_scores, sorted_indices] = sort(obj.Scores, 'descend');
            best_score = sorted_scores(1); % best scores
            second_best_score = sorted_scores(2); %basically nescores          
            if rand()<(1- (best_score-second_best_score)/25)
                obj.Next_Choice = obj.Choice_List(sorted_indices(2));
            else
                obj.Next_Choice = obj.Choice_List(sorted_indices(1));
            end
        end

        function scammyBehavior(obj)
            [~, sorted_indices] = sort(obj.Scores, 'ascend'); % Sort in ascending order to get the worst arms first
            if rand() < 0.60
                obj.Next_Choice = obj.Choice_List(sorted_indices(1)); % Choose the worst arm (index 1 after sorting in ascending order)
            else
                obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List))); % Random choice
            end
        end




    end
end


