classdef (Sealed, Hidden) NullHandler < element.Handler
    
    methods
        
        function obj = NullHandler()
            % Set properties to empty.
            obj@element.Handler()
        end
        
    end % methods
    
end