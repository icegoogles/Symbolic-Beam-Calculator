classdef beam < handle  % Balken
    properties
        beamlength = NaN
        pointloads = []
        lineloads = []
        torques = []
        bearings = []
        
        % equations
        sumForceX = NaN
        sumForceY = NaN
        sumTorque = NaN
        
        % shear and moment
        Q = NaN
        M = NaN
        
        % points of interest
        Q_points = []
        M_points = []
        
        % Areas with continuous Q and M equations
        % TODO
        
        % All symbolic variables used in equations
        symVars = []
        numReplace = []  % and their numeric replacements

        %% Errors
        subsError = ['Error substituting symbols with numeric values. ' ...
                    'Try setting symVars and numReplace!'];
        
    end
    %%
    methods
        % Constructor
        function obj = beam(length)
            obj.beamlength = length;
        end
        function [] = draw_points(obj)
            % drawing points of interest in active figure
            % works only numerically
            % TODO: make it possible for symbolic
            
            
            for i = 1:length(obj.Q_points)
                xPos = obj.Q_points(i).x;
                yPos = obj.Q_points(i).y;
                
                syms x
                test = subs(yPos, x, xPos);
                
                txt = sym2latex(test);  % create message
                
                % replacing symbolics to numeric values
                xPos = double(subs(xPos, obj.symVars, obj.numReplace));
                yPos = double(subs(yPos, obj.symVars, obj.numReplace));
                
                text(xPos, yPos, txt, 'Interpreter', "latex")
            end
            for i = 1:length(obj.M_points)
                xPos = obj.M_points(i).x;
                yPos = obj.M_points(i).y;
                
                txt = sym2latex(yPos);  % create message
                
                % replacing symbolics to numeric values
                xPos = double(subs(xPos, obj.symVars, obj.numReplace));
                yPos = double(subs(yPos, obj.symVars, obj.numReplace));
                
                text(xPos, yPos, txt, 'Interpreter', "latex")
            end
            
            
        end
        
        %%
        function [] = plot_Q(obj)
            % plot Q with given numeric values
            syms x;
            
            try
                % substitute symbolic values with numeric values
                Q_numeric = subs(obj.Q, obj.symVars, obj.numReplace);
                
                plotStart = 0;  % TODO: Implement custom starting position
                plotEnd = double(limit(subs(obj.beamlength, obj.symVars, obj.numReplace), x, obj.beamlength, 'right'));
            catch
                error(obj.subsError)
            end
            fplot(Q_numeric, [plotStart, plotEnd], 'Linewidth',3)
 
            title("Shear Force Diagram")
            ylabel('Q(x)')
            xlabel('x')
        end
        %%
        function [] = plot_M(obj)
            % plot M with given numeric values
            syms x;
            
            try
                % substitute symbolic values with numeric values
                M_numeric = subs(obj.M, obj.symVars, obj.numReplace);

                plotStart = 0;  % TODO: Implement custom starting position
                plotEnd = double(limit(subs(obj.beamlength, obj.symVars, obj.numReplace), x, obj.beamlength, 'right'));
            catch
                error(obj.subsError)
            end

            fplot(M_numeric, [plotStart, plotEnd], 'Linewidth',3)

            title("Bending Moment Diagram")
            ylabel('M(x)')
            xlabel('x')            
        end
        %%
        function [] = plot_beam(obj)
            % Visualize beam setup

            % TODO: custom start point
            try
                numBeamlength = double(subs(obj.beamlength, obj.symVars, obj.numReplace));
            catch
                error(obj.subsError)
            end

            scale = double(numBeamlength/30);  % size of bearings
            r = 1*scale;
            
            line([0, numBeamlength],[0, 0], 'LineWidth', 3, 'Color', 'b')  % draw beam
            xlabel('x')
            ylabel('(forces etc. not to scale)')

            % draw bearings
            for i = 1:length(obj.bearings)
                if obj.bearings(i).bearValue == 1  % 1 valued bearing        

                    px = double(subs(obj.bearings(i).position, obj.symVars, obj.numReplace));    
                    p = nsidedpoly(40, 'Center', [px, -r], 'Radius', r);
                    plot(p, 'FaceColor','yellow','EdgeColor','black');

                elseif obj.bearings(i).bearValue == 2  % 2 valued bearing

                    px = double(subs(obj.bearings(i).position, obj.symVars, obj.numReplace));
                    sk = 1.2;  % factor to make bearings the same size
                    r_new = r*sk;

                    p = nsidedpoly(3, 'Center', [px, -r_new], 'Radius', r_new);
                    plot(p, 'FaceColor','yellow','EdgeColor','black');

                elseif obj.bearings(i).bearValue == 3  % 3 valued bearing

                    px = double(subs(obj.bearings(i).position, obj.symVars, obj.numReplace));
                    
                    line([px, px],[-r, r], 'LineWidth', 4, 'Color', 'k')
                end
            end
            
            % draw pointloads
            for i = 1:length(obj.pointloads)
                
                val = double(subs(obj.pointloads(i).value, obj.symVars, obj.numReplace));
                xVal = double(subs(obj.pointloads(i).value_x, obj.symVars, obj.numReplace));
                yVal = double(subs(obj.pointloads(i).value_y, obj.symVars, obj.numReplace));
                pos = double(subs(obj.pointloads(i).position, obj.symVars, obj.numReplace));


                %quiver(pos + xVal, yVal, 0, yVal)
                fScale = scale*6;

                p1 = [pos + (xVal/val*fScale), -yVal/val*fScale];  % First Point
                p2 = [pos, 0];  % Second Point
                dp = p2 - p1;  % Difference
                quiver(p1(1),p1(2),dp(1),dp(2), 0, 'Color','magenta', 'LineWidth',1)
                text(p1(1),p1(2), string(abs(val)))
            end

            % draw torques
            for i = 1:length(obj.torques)
                
                val =  double(subs(obj.torques(i).value, obj.symVars, obj.numReplace));
                pos =  double(subs(obj.torques(i).position, obj.symVars, obj.numReplace));

                p = nsidedpoly(40, 'Center', [pos, 0], 'Radius', r/2);
                p2 = nsidedpoly(3, 'Center', [pos + r/2, 0], 'Radius', r/3);
                if val < 0
                    p2 = rotate(p2, 180, [pos + r/2, 0]);
                end
                plot(p, 'FaceColor','none','EdgeColor','red', 'LineWidth',2);
                plot(p2, 'FaceColor','red','EdgeColor','red','FaceAlpha',1);
                text(pos, -r, string(abs(val)))
            end

            % draw lineloads
            for i = 1:length(obj.lineloads)
                syms x
                startHight = subs(obj.lineloads(i).loadFunc, x, obj.lineloads(i).startPos);
                endHight =   subs(obj.lineloads(i).loadFunc, x, obj.lineloads(i).endPos);

                startHight = double(subs(startHight, obj.symVars, obj.numReplace));
                endHight =   double(subs(endHight, obj.symVars, obj.numReplace));

                startPos = double(subs(obj.lineloads(i).startPos, obj.symVars, obj.numReplace));
                endPos =   double(subs(obj.lineloads(i).endPos, obj.symVars, obj.numReplace));

                lineLoadFunc = subs(obj.lineloads(i).loadFunc, obj.symVars, obj.numReplace);
                
                % get scale
                x_num = linspace(startPos, endPos, 50);  % numeric x values
                lineLoadFunc_num = subs(lineLoadFunc,x,x_num);

                maxValue = max(abs(lineLoadFunc_num));

                lineLoadScale = scale*8;

                line([startPos, startPos],[0, startHight]/maxValue*lineLoadScale,'Color', [0, 0.5, 0])
                line([endPos, endPos],[0, endHight]/maxValue*lineLoadScale,'Color', [0, 0.5, 0])
                
                fplot(lineLoadFunc/maxValue * lineLoadScale, [startPos, endPos], 'Color', [0, 0.5, 0])
                
                text(startPos, startHight/maxValue*lineLoadScale, string(startHight))
                text(endPos, endHight/maxValue*lineLoadScale, string(endHight))
            end
            
            title("Free Body Diagram")

        end
        %%
        function [] = get_important_points(obj)
            syms x
            % Maximum is only numerically
%             % Shear-force points
%             eq2solve = 0 == diff(obj.Q, x);
%             outp = solve(eq2solve, x);
%             %figure(22)
%             %fplot(diff(obj.Q, x), x)
%             % TODO: Testing etc...
%             
%             % Bending-moment points
%             % maximum of bendingmoment (shear=0)
%             
%             eq2solve = 0 == obj.Q;
%             outp = solve(eq2solve, x);
%             disp('')

            % Add points from pointloads
            for i = 1:length(obj.pointloads)
                position = obj.pointloads(i).position;
                
%                 value_1 = limit(obj.Q, x, position, 'left');
%                 value_2 = limit(obj.Q, x, position, 'right');
                
                value_1 = limit(obj.Q, x, position);
                value_2 = limit(obj.Q, x, position);
                
                newPoint_1 = graphpoint(position, value_1);
                newPoint_2 = graphpoint(position, value_2);
                
                obj.Q_points = [obj.Q_points, newPoint_1, newPoint_2];
                
                % -------------------------------
                value_1 = limit(obj.M, x, position, 'left');
                value_2 = limit(obj.M, x, position, 'right');
                
                newPoint_1 = graphpoint(position, value_1);
                newPoint_2 = graphpoint(position, value_2);
                
                obj.M_points = [obj.M_points, newPoint_1, newPoint_2];
            end
            
            % Add points from bearings
            for i = 1:length(obj.bearings)
                position = obj.bearings(i).position;
                
                value_1 = limit(obj.Q, x, position, 'left');
                value_2 = limit(obj.Q, x, position, 'right');
                
                newPoint_1 = graphpoint(position, value_1);
                newPoint_2 = graphpoint(position, value_2);
                
                obj.Q_points = [obj.Q_points, newPoint_1, newPoint_2];
                
                % only if bearing can hold a moment
                if ~isnan(obj.bearings(i).Torque)
                    value_1 = limit(obj.M, x, position, 'left');
                    value_2 = limit(obj.M, x, position, 'right');
                    
                    newPoint_1 = graphpoint(position, value_1);
                    newPoint_2 = graphpoint(position, value_2);
                    
                    obj.M_points = [obj.M_points, newPoint_1, newPoint_2];
                end
                
            end
            
            % Add points from torques
            for i = 1:length(obj.torques)
                position = obj.torques(i).position;
                
                value_1 = limit(obj.M, x, position, 'left');
                value_2 = limit(obj.M, x, position, 'right');
                
                newPoint_1 = graphpoint(position, value_1);
                newPoint_2 = graphpoint(position, value_2);
                
                obj.M_points = [obj.M_points, newPoint_1, newPoint_2];
            end
            
            % Add points from lineloads
            for i = 1:length(obj.lineloads)
                pos_1 = obj.lineloads(i).startPos;
                pos_2 = obj.lineloads(i).endPos;
                
%                 valueQ_1 = limit(obj.Q, x, pos_1, 'right');
%                 valueQ_2 = limit(obj.Q, x, pos_2, 'left');
                
                valueQ_1 = limit(obj.Q, x, pos_1);
                valueQ_2 = limit(obj.Q, x, pos_2);
                
                valueM_1 = limit(obj.M, x, pos_1, 'right');
                valueM_2 = limit(obj.M, x, pos_2, 'left');
                
                newQPoint_1 = graphpoint(pos_1, valueQ_1);
                newQPoint_2 = graphpoint(pos_2, valueQ_2);
                
                newMPoint_1 = graphpoint(pos_1, valueM_1);
                newMPoint_2 = graphpoint(pos_2, valueM_2);
                
                obj.Q_points = [obj.Q_points, newQPoint_1, newQPoint_2];                    
                obj.M_points = [obj.M_points, newMPoint_1, newMPoint_2];
            end
            
            % remove duplicates
            obj.Q_points = unique(obj.Q_points);
            obj.M_points = unique(obj.M_points);
        end
        %%
        function [] = fullsolve(obj)
            % automatically solves beam
            obj.calc_sums_eq();
            obj.sol_bear_forces();
            obj.get_shear_force();
            
            obj.get_bend_moment();
            obj.get_important_points();
            
        end
        %%
        function [] = get_bend_moment(obj)
            obj.M = int(obj.Q);
            
            % add torques
            for i = 1:length(obj.torques)
                obj.M = obj.M + obj.torques(i).M;
            end
            
            % add bearing torques
            for i = 1:length(obj.bearings)
                if ~isnan(obj.bearings(i).Torque)
                	obj.M = obj.M + obj.bearings(i).M;
                end
            end

            % correct with factor C: M = M - C
            % find x where M(x) has to be 0
            
            x_zero = 0;  % TODO: custom start point
            for i = 1:length(obj.bearings)
                if obj.bearings(i).bearValue < 3  % found bearing where M(x)=0
                    x_zero = obj.bearings(i).position;
                    break
                % check if theres a bearing with value 3
                elseif obj.bearings(i).bearValue == 3
                    
                    if obj.bearings(i).position == 0
                        % choose end of beam where M(x)=0
                        x_zero = obj.beamlength;
                    else
                        x_zero = 0;
                        % choose beginning of beam where M(x)=0
                    end
                    break
                end
            end
            syms x
            C = subs(obj.M, x, x_zero);
            obj.M = simplify(obj.M - C);

        end
        %%
        function [] = get_shear_force(obj)
            % apply bearingforces in bearings
            for i = 1:length(obj.bearings)
                obj.bearings(i).addQAndM()
            end
            
            obj.Q = 0;
            % add pointloads
            for i = 1:length(obj.pointloads)
                obj.Q = obj.Q + obj.pointloads(i).Q;
            end
            % add bearingforces
            for i = 1:length(obj.bearings)
                obj.Q = obj.Q + obj.bearings(i).Q;
            end
            % add lineloads
            for i = 1:length(obj.lineloads)
                obj.Q = obj.Q + obj.lineloads(i).Q;
            end
            obj.Q = simplify(obj.Q);
            
        end
        %%
        function [] = sol_bear_forces(obj)
            
            % write needed equations into matrix
            eqs = [obj.sumForceX == 0, obj.sumForceY == 0, obj.sumTorque == 0];
            
            % find variables to solve for
            vars = [];
            
            for i = 1:length(obj.bearings)
                if ~isnan(obj.bearings(i).X)
                    vars = [vars, obj.bearings(i).X];
                end
                if ~isnan(obj.bearings(i).Y)
                    vars = [vars, obj.bearings(i).Y];
                end
                if ~isnan(obj.bearings(i).Torque)
                    vars = [vars, obj.bearings(i).Torque];
                end
            end
            
            %sol = solve(eqs, vars);  % using solve
            
            % using linsolve
            [A, B] = equationsToMatrix(eqs, vars);
            sol = linsolve(A, B);
            
            % write calculations to bearing(s) classes
            % using 'bruteforce' by going trough all bearings
            % TODO: bruteforcing is very inefficient, so it can be written
            % better (but on normal/simple operation it takes only 9 loops)
            for i = 1:length(vars)
                for k = 1:length(obj.bearings)
                    if obj.bearings(k).X == vars(i)
                        obj.bearings(k).X = sol(i);
                    elseif obj.bearings(k).Y == vars(i)
                        obj.bearings(k).Y = sol(i);
                    elseif obj.bearings(k).Torque == vars(i)
                        obj.bearings(k).Torque = sol(i);
                    end
                end
            end
            
        end
        %%
        function [] = calc_sums_eq(obj)
            %% y-direction equation
            y_func = 0;
            
            % Add pointloads
            for i = 1:length(obj.pointloads)
                y_func = y_func + obj.pointloads(i).value_y;
            end
            
            % Add lineloads
            for i = 1:length(obj.lineloads)
                y_func = y_func + obj.lineloads(i).area;
            end
            
            % Add Forces from Bearings
            for i = 1:length(obj.bearings)
                y_func = y_func + obj.bearings(i).Y;
            end 
            obj.sumForceY = y_func;
            
            %% x-direction equation
            x_func = 0;
            
            % Add pointloads
            for i = 1:length(obj.pointloads)
                x_func = x_func + obj.pointloads(i).value_x;
            end
            
            % Add forces from bearings
            for i = 1:length(obj.bearings)
                bearing = obj.bearings(i);
                if bearing.bearValue >= 2  % only if bearing can support it
                    x_func = x_func + obj.bearings(i).X;
                end
            end
            obj.sumForceX = x_func;
            
            %% Torque equation
            trque_func = 0;
            pivPos = obj.bearings(1).position;  % position of pivot point 
            
            % Add pointloads
            for i = 1:length(obj.pointloads)
                dist = obj.pointloads(i).position - pivPos;  % distance to pivot point
                trque_func = trque_func + obj.pointloads(i).value_y * dist;
            end

            % Add lineloads
            for i = 1:length(obj.lineloads)
                dist = obj.lineloads(i).CentOfGravPos - pivPos;  % distance to pivot point
                trque_func = trque_func + obj.lineloads(i).area * dist;
            end
            
            % Add forces and torques from bearings
            for i = 1:length(obj.bearings)
                dist = obj.bearings(i).position - pivPos;  % distance to pivot point
                trque_func = trque_func + obj.bearings(i).Y * dist;
                
                % Torqe for bearings with bearingvalue higher than 2
                if obj.bearings(i).bearValue >= 3
                    trque_func = trque_func + obj.bearings(i).Torque;
                end
            end
            
            % Add torques
            for i = 1:length(obj.torques)
                trque_func = trque_func + obj.torques(i).value;
            end 
            obj.sumTorque = trque_func;
            
        end

    end
end