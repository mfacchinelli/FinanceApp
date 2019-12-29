classdef (Abstract, Hidden) Handler < matlab.mixin.SetGetExactNames & matlab.mixin.Heterogeneous
    
    properties (Dependent, SetAccess = private)
        % Logical denoting whether the window is valid.
        IsValid
    end
    
    properties (Dependent, GetAccess = private)
        % Array specifying figure position.
        ParentPosition (1, 4) double {mustBeNonnegative}
    end % properties (Dependent, GetAccess = private)
    
    properties (Access = protected)
        % UI figure for obj.
        UIFigure matlab.ui.Figure
        % Grid layout for obj.
        Grid matlab.ui.container.GridLayout
    end % properties (Access = protected)
    
    methods
        
        function delete(obj)
            % Close figure to delete all children.
            obj.UIFigure.delete();
        end % destructor
        
        function value = get.IsValid(obj)
            if ~isvalid(obj)
                value = false;
            elseif isempty(obj.UIFigure)
                value = false;
            else
                value = isvalid(obj) && isgraphics(obj.UIFigure);
            end
        end % set.IsValid
        
        function set.ParentPosition(obj, value)
            % Define window size.
            size = [315, 120];
            
            % Compute position at middle of parent.
            position = value(1:2) + value(3:4) / 2 - size / 2;
            
            % Set window position.
            obj.UIFigure.Position = [position, size];
        end % set.ParentPosition
        
    end % methods
    
    methods (Access = protected)
        
        function createBasicComponents(obj)
            % CREATEBASICCOMPONENTS Internal function to create main
            % figure.
            
            % Create figure.
            obj.UIFigure = uifigure( ...
                "HandleVisibility", "off", ...
                "Resize", "off");
            
            % Hide figure until all components are created.
            obj.UIFigure.Visible = "off";
            
            % Create Grid.
            obj.Grid = uigridlayout(obj.UIFigure);
        end % createComponents
        
    end % methods (Access = protected)
    
end