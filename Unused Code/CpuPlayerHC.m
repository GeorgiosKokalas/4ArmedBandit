classdef CpuPlayerHC < handle
    properties
        Behavior_Mode   % Mode of Behavior, each mode interprets and reacts to the player's actions differently 
        Choice_List     % The list of choices that we have   
        Next_Choice     % The choice that will be made next by the Cpu
        Choice_Origins  % The start choice that we define
        Epsilon         % Sets the epsilon value for e-greedy algo
        Rewards         % Rewards received
        Counts          % Counts per choice
        Means           % Means for the arms
        Std_Devs        % Standard deviations for the arms
        Change_Prob     % Probability of changing arm's mean
    end

    methods
        % Constructor
        function obj = CpuPlayer(behavior_mode, choice_list, next_choice, epsilon, change_prob)
            if nargin < 1 || isempty(behavior_mode); behavior_mode = 1; end
            if nargin < 2 || isempty(choice_list); choice_list = ['A', 'B', 'C', 'D']; end
            if nargin < 3 || isempty(next_choice); next_choice = 'A'; end
            if nargin < 4 || isempty(epsilon); epsilon = 0.2; end
            if nargin < 5 || isempty(change_prob); change_prob = 0.05; end
            
            obj.Behavior_Mode = behavior_mode;
            obj.Choice_List = choice_list;
            obj.Epsilon = epsilon;
            obj.Change_Prob = change_prob;
            obj.Rewards = zeros(1, length(choice_list));
            obj.Counts = zeros(1, length(choice_list));
            obj.Next_Choice = next_choice;
            obj.Choice_Origins = next_choice;
            obj.initializeArms();
        end
        
        % Initialize the arms
        function initializeArms(obj)
            obj.Means = floor(5 + (95-5) * rand(1, length(obj.Choice_List)));
            obj.Std_Devs = randi([1, 3], 1, length(obj.Choice_List));
        end
        
        % Update the means of the arms
        function updateArms(obj)
            for arm = 1:length(obj.Choice_List)
                if rand() < obj.Change_Prob
                    obj.Means(arm) = floor(5 + (95-5) * rand());
                end
            end
        end
        
        % Get the points for the current state of the arms
        function points = getPoints(obj)
            points = obj.Means + obj.Std_Devs;
        end
        
        % Method that changes the behavior of the cpu 
        function changeBehavior(obj, varargin)
            % Update the means of the arms
            obj.updateArms();
            
            % Get the current points
            points = obj.getPoints();
            
            % Check if points and last choice were provided
            if length(varargin) >= 1
                last_choice = varargin{1};
                
                % Update rewards for the last choice
                choice_index = find(obj.Choice_List == last_choice);
                reward = points(choice_index);
                obj.updateRewards(last_choice, reward);
            end
            
            switch (obj.Behavior_Mode)
                case 1
                    % Code for Behavior 1 here: Epsilon Greedy
                    if rand() < obj.Epsilon
                        % Choose a random action with probability epsilon
                        obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
                    else
                        % Choose the best-known action with probability 1 - epsilon
                        [~, best_index] = max(obj.Rewards ./ max(1, obj.Counts));
                        obj.Next_Choice = obj.Choice_List(best_index);
                    end
                case 2
                    % Code for Behavior 2 here: Random choice
                    obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
            end
        end

        % Method that gives the cpu's response
        function Choice = getResponse(obj)
            Choice = obj.Next_Choice;
        end

        % Method to update rewards
        function updateRewards(obj, choice, reward)
            choice_index = find(obj.Choice_List == choice);
            obj.Rewards(choice_index) = obj.Rewards(choice_index) + reward;
            obj.Counts(choice_index) = obj.Counts(choice_index) + 1;
        end
    
        % Resets the CPU after every block
        function reset(obj)
            obj.Next_Choice = obj.Choice_Origins;
        end
    end
end
