classdef (Sealed, Hidden) Null < component.Component
    
    methods
        
        function obj = Null()
            % Set properties to empty.
            obj@component.Component(Finance)
        end
        
    end % methods
    
end