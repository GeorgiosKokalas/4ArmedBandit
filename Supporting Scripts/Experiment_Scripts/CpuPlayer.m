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
    end

    methods
        % Constructor
        function obj = CpuPlayer(behavior_mode, choice_list, next_choice)
            if ~exist("behavior_mode", "var"); behavior_mode = 1; end
            if ~exist("choice_list", "var"); choice_list = ['A', 'B', 'X']; end
            if ~exist("next_choice", "var"); next_choice = 'A'; end
            
            obj.Behavior_Mode = behavior_mode;
            obj.Choice_List = choice_list;
            [obj.Next_Choice, obj.Choice_Origins] = deal(next_choice);
        end
        
        % Method that changes the behavior of the cpu 
        function changeBehavior(obj)
             switch (obj.Behavior_Mode)
                 case 1
                     % Code for Behavior 1 here
                 case 2
                     % Code for Behavior 1 here
             end
        end

        % Method that gives the cpu's responce
        function Choice = getResponce(obj)
             switch (obj.Behavior_Mode)
                 case 1
                     % Code for Behavior 1 here
                 case 2
                     % Code for Behavior 1 here
             end
        end
    
        % Resets the CPU after every block
        function reset(obj)
           obj.Next_Choice = obj.Choice_Origins;
        end
    end
end