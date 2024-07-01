classdef CpuPlayerT < handle
    properties
        Behavior_Mode   % Mode of Behavior
        Choice_List     % List of choices
        Next_Choice     % Next choice to be made
        Choice_Origins  % Initial choice
        Epsilon         % Epsilon value for epsilon-greedy algorithm
        Rewards         % Rewards received
        Counts          % Counts per choice
        Behaviors       % Struct of behavior functions
    end
    
    methods
        % Constructor
        function obj = CpuPlayerT(behavior_mode, choice_list, next_choice, epsilon)
            if nargin < 4
                epsilon = 0.4;  % Default epsilon
            end
            if nargin < 3
                if nargin < 2
                    choice_list = ['A', 'B', 'C'];  % Default choice list
                end
                next_choice = choice_list(randi(length(choice_list)));  % Random initial choice
            end
            if nargin < 1
                behavior_mode = 1;  % Default behavior mode
            end
            
            obj.Behavior_Mode = behavior_mode;
            obj.Choice_List = choice_list;
            obj.Next_Choice = next_choice;
            obj.Choice_Origins = next_choice;
            obj.Epsilon = epsilon;
            
            obj.Rewards = zeros(1, length(choice_list));
            obj.Counts = zeros(1, length(choice_list));
            
            % Initialize behavior functions
            obj.Behaviors = struct(...
                'epsilonGreedy', @obj.epsilonGreedyBehavior, ...
                'randomChoice', @obj.randomChoiceBehavior ...
            );
        end
        
        % Method to change behavior
        function changeBehavior(obj, varargin)
            if nargin >= 3
                points = varargin{1};  % Button scores as points
                choice = varargin{2};
                disp(['Received choice: ', choice]);  % Debug print
                disp(['Received points: ', num2str(points)]); % Current choice
                obj.updateRewards(choice, points);  % Update rewards based on points
            end
            
            % Call appropriate behavior function
            behaviorFn = obj.getBehaviorFunction();
            obj.Next_Choice = behaviorFn();  % Determine next choice
        end
        
        % Epsilon-greedy behavior
        function nextChoice = epsilonGreedyBehavior(obj)
            if rand() < obj.Epsilon
                nextChoice = obj.Choice_List(randi(length(obj.Choice_List)));
            else
                [~, best_indices] = max(obj.Rewards ./ max(1, obj.Counts));  % Use average best reward
                nextChoice = obj.Choice_List(best_indices(randi(length(best_indices))));
            end
        end
        
        % Random choice behavior
        function nextChoice = randomChoiceBehavior(obj)
            nextChoice = obj.Choice_List(randi(length(obj.Choice_List)));
        end
        
        % Get current choice
        function choice = getResponse(obj)
            choice = obj.Next_Choice;
            disp(choice)
        end
        
        % Update rewards based on choice and points
        function updateRewards(obj, choice, points)
            choice_index = find(obj.Choice_List == choice, 1);
            if ~isempty(choice_index)
                obj.Rewards(choice_index) = obj.Rewards(choice_index) + points;  % Accumulate points as rewards
                obj.Counts(choice_index) = obj.Counts(choice_index) + 1;  % Increment count for the choice
            end
        end
        
        % Reset CPU player
        % function reset(obj)
        %     obj.Next_Choice = obj.Choice_Origins;
        %     obj.Rewards = zeros(1, length(obj.Choice_List));
        %     obj.Counts = zeros(1, length(obj.Choice_List));
        % end
        
    end
    
    methods (Access = private)
        % Determine behavior function based on mode
        function behaviorFn = getBehaviorFunction(obj)
            switch obj.Behavior_Mode
                case 1
                    behaviorFn = obj.Behaviors.epsilonGreedy;
                case 2
                    behaviorFn = obj.Behaviors.randomChoice;
                otherwise
                    error('Unknown behavior mode');
            end
        end
    end
    
end
