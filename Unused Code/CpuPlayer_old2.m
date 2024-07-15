% A class that defines a cpu player.
% It can currently:
%   - Adapt its behavior (changeBehavior)
%   - Respond to a choice (getResponce)
%   - Reset (reset)

classdef CpuPlayer < handle
    properties
        Behavior_Mode   % Mode of Behavior, each mode interprets and reacts to the player's actions differently 
        Choice_List     % The list of choices that we have   
        Next_Choice     % The choice that will be made next by the Cpu
        Prev_Choice     % The most recent choice made by the current Cpu
        Choice_Origins  % The start choice that we define
        Epsilon         % Sets the epsilon value for e-greedy algo
        Rewards         % Rewards received
        Counts          % Counts per choice
        Behaviors       % A struct of behavior functions
    end

    methods
        % Constructor, this sets up default mode
        function obj = CpuPlayer(behavior_mode, choice_list, next_choice, epsilon)
            if ~exist("behavior_mode", "var") || isempty(behavior_mode)
                behavior_mode = 1; 
            end
            if ~exist("choice_list", "var") || isempty(choice_list)
                choice_list = ['A', 'B', 'X']; 
            end
            if ~exist("next_choice", "var")  || isempty(next_choice)
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
        end
        
        % General method to change behavior
        function changeBehavior(obj, points)
            obj.updateRewards(points); % Update the memory of the choices that we made

            switch obj.Behavior_Mode  % Different functions based on behaviors
                case 1
                    obj.epsilonGreedyBehavior();
                case 2
                    obj.randomChoiceBehavior();
                otherwise
                    error('Unknown behavior mode');
            end
        end        

        % General method to observe the player's choices
        % function observePlayer(obj, choice, score)
        %     switch obj.Behavior_Mode
        %         case 1
        %         case 2
        %     end
        % end
        
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
        end

    end
    
    % Methods used by the class internally
    methods (Access = private)
        % Method that updates choices and rewards
        function updateRewards(obj, reward)
            choice_index = find(obj.Choice_List == obj.Prev_Choice, 1);
            if ~isempty(choice_index)
                obj.Rewards(choice_index) = obj.Rewards(choice_index) + reward;
                obj.Counts(choice_index) = obj.Counts(choice_index) + 1;
            end
        end
        %% Observational Functions 
        % A sort of Q learning approach based on player and CPU
        % observations
        



        
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
        % function cheaterBehavior(obj)
        %     obj.Next_Choice =
        % end
    end
end
