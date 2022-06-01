classdef torque < handle
    properties
        position = 0
        value = 0
        
        % Föppl part
        M = 0
    end
    methods
        % Constructor
        function obj = torque(position, value)
            obj.position = position;
            obj.value = value;
            
            % calc föppl part
            syms x;
            obj.M = -obj.value * H(x - position);
        end
    end
end