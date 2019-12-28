classdef (Abstract, Hidden) Component < element.Element
    
    properties (Dependent)
        % Parent of main component.
        Parent
        % Layout of main component.
        Layout
        % Context menu of main component.
        ContextMenu
    end % properties (Dependent)
    
    properties (Access = protected)
        % Main component.
        Main
        % Grid containing object.
        Grid matlab.ui.container.GridLayout
    end % properties (Access = protected)
    
    methods
        
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