classdef pointload < handle  % Punktlast
    properties
        position = 0
        value = 0
        value_x = 0
        value_y = 0
        angle = sym(pi/2);  % [RAD]
        
        % Föppl part
        Q = 0
    end
    methods
        % Constructor
        function obj = pointload(position, value, angleDEG)
            obj.position = position;
            obj.value = value;
            if nargin == 3
                obj.angle = deg2rad(sym(angleDEG));                
            end
            obj.value_x =  value * cos(obj.angle);
            obj.value_y = -value * sin(obj.angle);


            % calc föppl parts
            syms x;
            obj.Q = obj.value_y * H(x - position);
        end
    end 
end