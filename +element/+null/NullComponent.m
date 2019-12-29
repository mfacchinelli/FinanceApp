classdef (Sealed, Hidden) NullComponent < element.Component
    
    methods
        
        function obj = NullComponent()
            % Set properties to empty.
            obj@element.Component()
        end
        
    end % methods
    
end