classdef (Sealed, Hidden) Null < element.Component
    
    methods
        
        function obj = Null()
            % Set properties to empty.
            obj@element.Component()
        end
        
    end % methods
    
end