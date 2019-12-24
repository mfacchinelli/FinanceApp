classdef (Abstract) Handler < matlab.mixin.SetGetExactNames
    
    properties (Access = protected)
        % UI figure for obj.
        UIFigure matlab.ui.Figure
        % Grid layout for obj.
        GridLayout matlab.ui.container.GridLayout
    end % properties (Access = private)
    
    methods (Access = protected)
        
        function createComponents(obj)
            % CREATECOMPONENTS Internal function to create UIFigure for obj
            % and its components - text box and edit field - based on the
            % input text strings.
            
            % Create UIFigure and hide until all components are created.
            obj.UIFigure = uifigure("Visible", "off", "HandleVisibility", "off");
            
            % Create GridLayout.
            obj.GridLayout = uigridlayout(obj.UIFigure);
        end
        
    end % methods (Sealed, Access = protected)
    
end