classdef (Abstract, Hidden) ComponentWithPanel < component.Component
    
    methods
        
        function obj = ComponentWithPanel(model)
            % Call superclass constructor.
            obj@component.Component(model)
            
            % Create panel.
            % Set parent to invisible uifigure, to make sure web graphics
            % are used as default.
            f = uifigure("Visible", "off", "HandleVisibility", "off");
            obj.Main = uipanel("Parent", f);
            obj.Main.Parent = [];
        end % constructor
        
    end % methods
    
end