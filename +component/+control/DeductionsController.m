classdef DeductionsController < component.Component
    
    properties
        % String defining the name of the tracked property of the model.
        TrackedProperty string = string.empty()
    end % properties
    
    properties (Dependent, SetAccess = private)
        % Variable returning context menu.
        UIContextMenu
    end % properties (Dependent, SetAccess = private)
    
    properties (Access = private)
        % Array of submenus.
        Menus (1, :) matlab.ui.container.Menu = matlab.ui.container.Menu.empty()
        % Dialog app to add or remove deductions.
        Dialog window.DeductionDlg = window.DeductionDlg.empty()
        % Listener to dialog app.
        DialogListener (1, 1)
    end % properties (Access = private)
    
    methods
        
        function obj = DeductionsController(model, varargin)
            % Call superclass constructor.
            obj@component.Component(model)
            
            % Create button group.
            % Main - Context menu for submenus.
            obj.Main = uicontextmenu("Parent", []);
            
            % Add submenu to add deduction.
            obj.Menus(1) = uimenu(obj.Main, ...
                "Text", "&Add", ...
                "Accelerator", "A", ...
                "MenuSelectedFcn", @obj.onAdd);
            
            % Add submenu to remove deduction.
            obj.Menus(1) = uimenu(obj.Main, ...
                "Text", "&Remove", ...
                "Accelerator", "R", ...
                "MenuSelectedFcn", @obj.onRemove);
            
            % Set properties.
            set(obj, varargin{:})
        end % constructor
        
        function delete(obj)
            % Delete input dialog.
            if isvalid(obj.Dialog)
                delete(obj.Dialog);
            end
        end % destructor
        
        function set.TrackedProperty(obj, value)
            % Check that the property is acutally part of the model.
            if ~isempty(value)
                assert(isprop(obj.Model, value), "DeductionsController:TrackedProperty:InvalidInput", ...
                    "Name of tracked property must valid.")
            end
            
            % Set value.
            obj.TrackedProperty = value;
        end % set.TrackedProperty
        
        function value = get.UIContextMenu(obj)
            value = obj.Main;
        end % get.UIContextMenu
        
    end % methods
    
    methods (Access = private)
        
        function onAdd(obj, ~, ~)
            % ONADD Internal function to create dialog input to add
            % deductions.
            
            % Call UI dialog app.
            obj.Dialog = window.DeductionDlg("addDeduction", ...
                obj.Parent.Position(1:2) + obj.Parent.Position(3:4) / 3);
            if isvalid(obj.Dialog)
                obj.DialogListener = listener(obj.Dialog, "OKPushed", @obj.onAddOK);
            end
        end % onAdd
        
        function onAddOK(obj, ~, ~)
            % ONADDOK Internal function to add deduction to finance model.
            
            % Retrieve edit field value.
            value = obj.Dialog.EditFieldValue;
            
            % Split and check value at semicolons.
            splitvalue = strip(strsplit(value, ";"));
            assert(numel(splitvalue) == 4, "DeductionsController:Dialog:WrongSize", ...
                "When adding a deduction you must specify all inputs (name, value, currency, and recurrence).")
            
            % Convert values to supported.
            splitvalue = cellfun(@string, splitvalue, "UniformOutput", false);
            splitvalue{2} = str2double(splitvalue{2}); %#ok<NASGU>
            
            % Pass information to model for further processing.
            try
                eval(sprintf("obj.Model.add%sDeduction(splitvalue{:})", obj.TrackedProperty))
            catch exception
                if strcmp(exception.identifier, "MATLAB:noSuchMethodOrField")
                    error("DeductionsController:Add:InvalidProperty", ...
                        "Selected property does not have an add method.")
                else
                    rethrow(exception)
                end
            end
        end % onAddOK
        
        function onRemove(obj, ~, ~)
            % ONREMOVE Internal function to remove deduction from finance
            % model.
            
            % Call UI dialog app.
            obj.Dialog = window.DeductionDlg("removeDeduction", ...
                obj.Parent.Position(1:2) + obj.Parent.Position(3:4) / 3);
            if isvalid(obj.Dialog)
                obj.DialogListener = listener(obj.Dialog, "OKPushed", @obj.onRemoveOK);
            end
        end % onRemove
        
        function onRemoveOK(obj, ~, ~)
            % ONREMOVEOK Internal function to remove deduction from finance
            % model.
            
            % Retrieve edit field value.
            value = obj.Dialog.EditFieldValue;
            
            % Split and check value at semicolons.
            splitvalue = strip(strsplit(value, ";"));
            assert(~isempty(splitvalue) || strcmp(splitvalue, ""), "DeductionsController:Dialog:WrongSize", ...
                "When removing a deduction you must specify at least one row.")
            
            % Convert values to supported.
            splitvalue = str2double(splitvalue); %#ok<NASGU>
            
            % Pass information to model for further processing.
            try
                eval(sprintf("obj.Model.remove%sDeduction(splitvalue)", obj.TrackedProperty))
            catch exception
                if strcmp(exception.identifier, "MATLAB:noSuchMethodOrField")
                    error("DeductionsController:Remove:InvalidProperty", ...
                        "Selected property does not have a remove method.")
                else
                    rethrow(exception)
                end
            end
        end % onRemoveOK
        
    end % methods (Access = private)
    
end