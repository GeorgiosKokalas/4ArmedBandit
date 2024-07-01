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
        Choice_Origins  % The start choice that we define
        Epsilon         % Sets the epsilon value for e-greedy algo
        Rewards         % Rewards received
        Counts          % Counts per choice
    end

    methods
        % Constructor, this sets up default mode
        function obj = CpuPlayer(behavior_mode, choice_list, next_choice)
            if ~exist("behavior_mode", "var"); behavior_mode = 1; end
            if ~exist("choice_list", "var"); choice_list = ['A', 'B', 'X']; end
            % if ~exist("next_choice", "var"); next_choice = 'A'; end
            if ~exist("next_choice", "var"); next_choice = choice_list(randi(length(choice_list))); end
            if ~exist("epsilon", "var"); epsilon = 0.4; end
            
            obj.Behavior_Mode = behavior_mode;
            obj.Choice_List = choice_list;
            obj.Epsilon = epsilon;
            obj.Rewards = zeros(1, length(choice_list));
            obj.Counts = zeros(1, length(choice_list));
            obj.Next_Choice = next_choice;
            obj.Choice_Origins = next_choice;
            
        end
        
        function changeBehavior(obj, varargin)           %changeBehavior(obj)
            % varargin can contain the points and choice made
            if ~isempty(varargin)
                points = varargin{1};
                choice = varargin{2};
                % Update rewards and counts
                obj.updateRewards(choice, points);
            end
            
            switch obj.Behavior_Mode
                case 1
                    % Epsilon Greedy
                    if rand() < obj.Epsilon
                        % Choose a random arm with probability epsilon
                        obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
                    else
                        % Choose the best-known action with probability 1 -
                        % epsilon, aka choose the arm with the highest
                        % average rewards
                        [~, best_index] = max(obj.Rewards ./ max(1, obj.Counts));
                        obj.Next_Choice = obj.Choice_List(best_index);
                    end

                case 2
                    % Random choice
                    obj.Next_Choice = obj.Choice_List(randi(length(obj.Choice_List)));
            end
        end
         % Method that gives the cpu's response
        function Choice = getResponse(obj)
            Choice = obj.Next_Choice;
        end
        % Method that updates choices and rewards
        function updateRewards(obj, choice, reward)
            choice_index = find(obj.Choice_List == choice);
            obj.Rewards(choice_index) = obj.Rewards(choice_index) + reward;
            obj.Counts(choice_index) = obj.Counts(choice_index) + 1;
        end  
        % Resets the CPU after every block
         function reset(obj)
            obj.Next_Choice = obj.Choice_Origins;
            obj.Rewards = zeros(1, length(obj.Choice_List));
            obj.Counts = zeros(1, length(obj.Choice_List));
        end
    end
end