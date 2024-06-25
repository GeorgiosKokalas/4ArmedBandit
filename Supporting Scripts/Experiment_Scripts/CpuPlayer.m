% A class that defines a cpu player.
% It can currently:
%   - Adapt its behavior (changeBehavior)
%   - Respond to a choice (getResponce)
%   - Reset (reset)

classdef CpuPlayer < handle
    properties
        Behavior_Mode   % Mode of Behavior, each mode interprets and reacts to the player's actions differently    
    end

    methods
        % Constructor
        function obj = CpuPlayer(behavior_mode)
            if ~exist("behavior_mode", "var"); behavior_mode = 1; end
            
            obj.Behavior_Mode = behavior_mode;
        end
        
        % Method that changes the behavior of the cpu 
        function changeBehavior(obj)
             
        end

        % Method that gives the cpu's responce
        function choice = getResponce(obj)
             
        end
    
        % Resets the CPU after every block
        function reset(obj)
           
        end
    end
end