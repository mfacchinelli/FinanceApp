classdef (Abstract, Hidden) ComponentWithListener < element.Component
    
    properties (Access = protected)
        % Listener to model data.
        Listener (1, 1)
    end % properties (Access = protected)
    
    methods
        
        function obj = ComponentWithListener(model)
            % Call superclass constructor.
            obj@element.Component(model)
            
            % Add listener to model data.
            obj.Listener = listener(obj.Model, "Update", @obj.onUpdate);
        end % constructor
        
    end % methods
    
    methods (Abstract, Access = protected)
        
        onUpdate(obj, src, event)
        
    end % methods (Access = protected)
    
end