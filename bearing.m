classdef bearing < handle  % Punktlast
    properties
        position = 0
        bearValue = 0  % Lagerwertigkeit
        name = NaN  % name of position/bearing
        
        X = NaN
        Y = NaN
        Torque = NaN
        
        % shears and moment
        Q = NaN
        M = NaN
    end
    methods
        % Constructor
        function obj = bearing(position, bearValue, name)
            obj.position = position;
            obj.bearValue = bearValue;

            obj.name = str2sym(name);
            if bearValue >= 1
                obj.Y = str2sym(strcat(name, '_y'));
            end
            if bearValue >= 2
                obj.X = str2sym(strcat(name, '_x'));
            end
            if bearValue >= 3
                obj.Torque = str2sym(strcat(name, '_tque'));
            end
            
        end
        function [] = addQAndM(obj)
            syms x
            obj.Q = obj.Y * H(x - obj.position);
            % if bearing can support bending moment
            if obj.bearValue >= 3
                obj.M = -obj.Torque * H(x - obj.position);
            end
        end
    end
end