classdef (Abstract, Hidden) EditFieldHandler < element.InputHandler
    
    properties (Dependent, SetAccess = private)
        % Access value of input.
        InputValue
    end % properties (Dependent, SetAccess = private)
    
    properties (Access = protected)
        % Edit field to capture own text.
        EditField matlab.ui.control.EditField
    end % properties (Access = protected)
    
    methods
        
        function value = get.InputValue(obj)
            value = obj.EditField.Value;
        end % get.InputValue
        
    end % methods
    
    methods (Access = protected)
        
        function createBasicComponents(obj)
            % CREATEBASICCOMPONENTS Internal function to create app
            % components.
            
            % Call superclass method.
            obj.createBasicComponents@element.InputHandler()
            
            % Create EditField.
            obj.EditField = uieditfield(obj.Grid, "text");
        end % createComponents
        
    end % methods (Access = protected)
    
end