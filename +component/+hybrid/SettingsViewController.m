classdef (Sealed) SettingsViewController < component.ComponentWithListenerPanel
    
    properties (Access = private)
        % Edit box showing the gross income value.
        GrossIncomeField (1, 1)
        % Edit box showing the net income value.
        NetIncomeField (1, 1)
    end
    
    methods
        
        function obj = SettingsViewController(model, varargin)
            % Call superclass constructors.
            obj@component.ComponentWithListenerPanel(model)
            
            % Create grid.
            obj.Grid = uigridlayout(obj.Main, [1, 2]);
            
            % Create .
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show data.
            obj.onUpdate();
        end % constructor
        
    end % methods
    
    methods (Access = protected)
        
        function onUpdate(obj, ~, ~)
            % ONUPDATE Internal function to update the income values with
            % new model data. This function is triggered by a listener on
            % the Finance object 'Update' event.
            
        end % onUpdate
        
    end % methods (Access = protected)
    
    methods (Access = private)
        
    end % methods (Access = private)
    
end