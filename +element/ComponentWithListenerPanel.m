classdef (Abstract, Hidden) ComponentWithListenerPanel < element.ComponentWithListener
    
    methods
        
        function obj = ComponentWithListenerPanel(model)
            % Call superclass constructor.
            obj@element.ComponentWithListener(model)
            
            % Create panel.
            % Main - Panel containing elements.
            % Set parent to invisible uifigure, to make sure web graphics
            % are used as default.
            f = uifigure("Visible", "off", "HandleVisibility", "off");
            obj.Main = uipanel("Parent", f);
            obj.Main.Parent = [];
            f.delete();
        end % constructor
        
    end % methods
    
end