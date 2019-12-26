classdef (Abstract, Hidden) Component < matlab.mixin.SetGetExactNames & matlab.mixin.Heterogeneous
    
    properties (Dependent)
        % Parent of main component.
        Parent
        % Layout of main component.
        Layout
        % Context menu of main component.
        ContextMenu
    end % properties (Dependent)
    
    properties (SetAccess = immutable, GetAccess = protected)
        % Model describing the finance structure.
        Model Finance = Finance.empty()
    end % properties (SetAccess = immutable, GetAccess = protected)
    
    properties (Access = protected)
        % Main component.
        Main (1, 1)
        % Grid containing object.
        Grid matlab.ui.container.GridLayout
    end % properties (Access = protected)
    
    methods
        
        function obj = Component(model)
            % Assign model to object.
            if nargin > 0
                assert(isa(model, "Finance"), "Component:Model:InvalidInput", ...
                    "Model must be of type Finance.")
                obj.Model = model;
            end
        end % constructor
        
        function set.Parent(obj, value)
            obj.Main.Parent = value;
        end % set.Parent
        
        function value = get.Parent(obj)
            value = obj.Main.Parent;
        end % set.Parent
        
        function set.Layout(obj, value)
            obj.Main.Layout = value;
        end % set.Layout
        
        function value = get.Layout(obj)
            value = obj.Main.Layout;
        end % set.Layout
        
        function set.ContextMenu(obj, value)
            obj.Main.ContextMenu = value;
        end % set.ContextMenu
        
        function value = get.ContextMenu(obj)
            value = obj.Main.ContextMenu;
        end % set.ContextMenu
        
    end % methods
    
end