classdef graphpoint < handle
    % point that saves the value of an important graphpoint
    properties
        x = 0
        y = 0
    end
    methods
        % Constructor
        function obj = graphpoint(x,y)
            obj.x = x;
            obj.y = y;
        end
    end
end