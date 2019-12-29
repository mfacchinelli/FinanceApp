classdef (Sealed, Hidden) NullElement < element.Element
    
    methods
        
        function obj = NullElement()
            % Set properties to empty.
            obj@element.Element()
        end
        
    end % methods
    
end