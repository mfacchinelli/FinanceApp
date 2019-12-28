classdef (Abstract, Hidden) Element < matlab.mixin.SetGetExactNames & matlab.mixin.Heterogeneous
    
    properties (SetAccess = immutable, GetAccess = protected)
        % Model describing the finance structure.
        Model Finance = Finance.empty()
    end % properties (SetAccess = immutable, GetAccess = protected)
    
    methods
        
        function obj = Element(model)
            % Assign model to object.
            if nargin > 0
                assert(isa(model, "Finance"), "Component:Model:InvalidInput", ...
                    "Model must be of type Finance.")
                obj.Model = model;
            end
        end % constructor
        
    end % methods
    
end