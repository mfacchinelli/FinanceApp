classdef (Abstract, Hidden) Element < matlab.mixin.SetGetExactNames & matlab.mixin.Heterogeneous
    
    properties (SetAccess = immutable, GetAccess = protected)
        % Model describing the finance structure.
        Model Finance = Finance.empty()
    end % properties (SetAccess = immutable, GetAccess = protected)
    
    methods
        
        function obj = Element(model)
            arguments
                model Finance = Finance.empty()
            end
            
            % Assign model to object.
            obj.Model = model;
        end % constructor
        
    end % methods
    
end