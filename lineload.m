classdef lineload < handle  % Streckenlast
    properties
        startPos = 0
        endPos = 0
        loadFunc = 0
        
        area = 0
        CentOfGravPos = 0
        
        % shear and moment
        Q = 0
        % the bending moment (M) is calculated after full
        % shear-force-calculation and is not calculated in this class
        M = 0
        
    end
    methods
        % Constructor
        function obj = lineload(startPos, endPos, loadFunc)
            obj.startPos = startPos;
            obj.endPos = endPos;
            obj.loadFunc = loadFunc;
            
            obj.set_cent_of_grav();
            obj.addQAndM();
        end
        function addQAndM(obj)
            syms x;
            % Shear
            Q1 = -int(obj.loadFunc, x);
            startValue = subs(Q1, x, obj.startPos);
            endValue = subs(Q1, x, obj.endPos);
            
            obj.Q = Q1 * (H(x - obj.startPos) - H(x - obj.endPos));
            obj.Q = obj.Q + endValue * H(x - obj.endPos);
            obj.Q = obj.Q - startValue * H(x - obj.startPos);
            
%             figure(10)
%             syms C1 C2 l 
%             AA = subs(obj.Q,[C1, C2, l],[0,0, 10]);
%             fplot(AA,[-1,11]) 
            
            % Moment is calculated in beam class ('get_bend_moment()')
            %M1 = int(Q1, x);
            %obj.M = M1 * (H(x - obj.startPos) - H(x - obj.endPos));
        end
        function set_cent_of_grav(obj)
            % Calculates and sets center of gravity
            % This also calculates Area
            syms x y;
            func = obj.loadFunc;
            region = [obj.startPos, obj.endPos];
            
            A = int(func, x, region);
            COG = 1/A * int(int(x,y,[0, func]), x, region);
            
            obj.area = -A;
            obj.CentOfGravPos = COG;
        end
    end
end