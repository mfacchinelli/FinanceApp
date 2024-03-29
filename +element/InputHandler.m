classdef (Abstract, Hidden) InputHandler < element.Handler
    
    properties (Abstract, Dependent, SetAccess = private)
        % Access value of input.
        InputValue
    end % properties (Abstract, Dependent, SetAccess = private)
    
    properties (GetAccess = private)
        % Callback for OK button pushed.
        OKFcn function_handle = function_handle.empty()
        % Callback for Cancel button pushed.
        CancelFcn function_handle = function_handle.empty()
    end % properties (Dependent, GetAccess = private)
    
    properties (Access = protected)
        % Label to show custom text.
        Label matlab.ui.control.Label
        % Button to return edit field value to main obj.
        OKButton matlab.ui.control.Button
        % Button to cancel transaction and delete obj.
        CancelButton matlab.ui.control.Button
    end % properties (Access = protected)
    
    methods
        
        function obj = InputHandler()
            % Create basic components.
            obj.createBasicComponents();
            
            % Specify position of components.
            obj.setLayout();
        end % constructor
        
    end % methods
    
    methods (Abstract, Access = protected)
        
        setLayout(obj)
        
    end % methods (Abstract, Access = protected)
    
    methods (Access = protected)
        
        function createBasicComponents(obj)
            % CREATEBASICCOMPONENTS Internal function to create app
            % components.
            
            % Call superclass method.
            obj.createBasicComponents@element.Handler()
            
            % Create Label.
            obj.Label = uilabel(obj.Grid);
            obj.Label.HorizontalAlignment = "left";
            obj.Label.VerticalAlignment = "center";
            
            % Create OKButton.
            obj.OKButton = uibutton(obj.Grid, "push");
            obj.OKButton.Text = "OK";
            obj.OKButton.ButtonPushedFcn = @obj.onOK;
            
            % Create CancelButton.
            obj.CancelButton = uibutton(obj.Grid, "push");
            obj.CancelButton.Text = "Cancel";
            obj.CancelButton.ButtonPushedFcn = @obj.onCancel;
        end % createComponents
        
    end % methods (Access = protected)
    
    methods (Access = private)
        
        function onOK(obj, ~, ~)
            % ONOK Internal function acting as callback wrapper for OK
            % button.
            
            % Call user-defined callback.
            if ~isempty(obj.OKFcn)
                obj.OKFcn()
            end
            
            % Delete handler.
            obj.delete();
        end % onOK
        
        function onCancel(obj, ~, ~)
            % ONCANCEL Internal function acting as callback wrapper for
            % Cancel button.
            
            % Call user-defined callback.
            if ~isempty(obj.CancelFcn)
                obj.CancelFcn()
            end
            
            % Delete handler.
            obj.delete();
        end % onCancel
        
    end % methods (Access = private)
    
end