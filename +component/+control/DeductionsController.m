classdef DeductionsController < component.Component
    
    properties (Dependent)
        % String defining the name of the tracked property of the model.
        TrackedProperty string
    end % properties (Dependent)
    
    properties (Dependent, SetAccess = private)
        % Variable returning context menu.
        UIContextMenu
    end % properties (Dependent, SetAccess = private)
    
    properties (Access = private)
        % Array of submenus.
        Menus (1, :) matlab.ui.container.Menu = matlab.ui.container.Menu.empty()
        % Dialog app to add or remove deductions.
        Dialog component.window.DeductionsHandler = component.window.DeductionsHandler.empty()
        % Listener to dialog app.
        DialogListener (1, 1)
        % Internal value of the tracked property of the model.
        TrackedProperty_ string = string.empty()
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
            obj.Menus(2) = uimenu(obj.Main, ...
                "Text", "Remove...");
            
            obj.Menus(3) = uimenu(obj.Menus(2), ...
                "Text", "&Rows", ...
                "Accelerator", "R", ...
                "MenuSelectedFcn", @obj.onRemoveRows);
            
            obj.Menus(4) = uimenu(obj.Menus(2), ...
                "Text", "&Everything", ...
                "Accelerator", "E", ...
                "MenuSelectedFcn", @obj.onRemoveEverything);
            
            % Set properties.
            set(obj, varargin{:})
        end % constructor
        
        function delete(obj)
            % Delete input dialog.
            if isvalid(obj.Dialog)
                obj.Dialog.delete();
            end
        end % destructor
        
        function set.TrackedProperty(obj, value)
            % Check that the property is acutally part of the model.
            if ~isempty(value)
                assert(isprop(obj.Model, value), "DeductionsController:TrackedProperty:InvalidInput", ...
                    "Name of tracked property must valid.")
            end
            
            % Set value.
            obj.TrackedProperty_ = value;
        end % set.TrackedProperty
        
        function value = get.TrackedProperty(obj)
            value = obj.TrackedProperty_;
        end % get.TrackedProperty
        
        function value = get.UIContextMenu(obj)
            value = obj.Main;
        end % get.UIContextMenu
        
    end % methods
    
    methods (Access = private)
        
        function onAdd(obj, ~, ~)
            % ONADD Internal function to create dialog input to add
            % deductions.
            
            % Check that no other window is open.
            if isempty(obj.Dialog) || ~obj.Dialog.IsValid
                % Call UI dialog app.
                obj.Dialog = component.window.DeductionsHandler( ...
                    "Mode", "add", ...
                    "Position", obj.Parent.Position(1:2) + obj.Parent.Position(3:4) / 3, ...
                    "OKFcn", @obj.onAddOK);
            else
                uialert(obj.Parent, ["A window of this kind is already open. ", ...
                    "Please finish the previous operation before starting a new one."], ...
                    sprintf("%s Input Dialog Already Open", obj.TrackedProperty_), ...
                    "Icon", "warning");
            end
        end % onAdd
        
        function onRemoveRows(obj, ~, ~)
            % ONREMOVEROWS Internal function to remove specific deductions
            % from finance model.
            
            % Check that no other window is open.
            if isempty(obj.Dialog) || ~obj.Dialog.IsValid
                % Call UI dialog app.
                obj.Dialog = component.window.DeductionsHandler( ...
                    "Mode", "remove", ...
                    "Position", obj.Parent.Position(1:2) + obj.Parent.Position(3:4) / 3, ...
                    "OKFcn", @obj.onRemoveRowsOK);
            else
                uialert(obj.Parent, ["A window of this kind is already open. ", ...
                    "Please finish the previous operation before starting a new one."], ...
                    "Input Dialog Already Open", ...
                    "Icon", "warning");
            end
        end % onRemoveRows
        
        function onRemoveEverything(obj, ~, ~)
            % ONREMOVEEVERYTHING Internal function to remove all deduction
            % from finance model.
            
            % Remove all deductions.
            uiconfirm(obj.Parent, ...
                "Do you wish to remove all deductions? This cannot be undone.", ...
                sprintf("Remove All %s Deductions", obj.TrackedProperty_), ...
                "Options", ["OK", "Cancel"], ...
                "Icon", "Warning", ...
                "CloseFcn", @obj.onRemoveEverythingOK);
        end % onRemoveEverything
        
    end % methods (Access = private)
    
    methods (Access = ?component.window.DeductionsHandler)
        
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
                eval(sprintf("obj.Model.add%sDeduction(splitvalue{:});", obj.TrackedProperty_))
            catch exception
                if strcmp(exception.identifier, "MATLAB:noSuchMethodOrField")
                    error("DeductionsController:Add:InvalidProperty", ...
                        "Selected property does not have an add method.")
                else
                    uialert(obj.Parent, exception.message, ...
                        sprintf("Caught Exception - %s", exception.identifier));
                end
            end
        end % onAddOK
        
        function onRemoveRowsOK(obj, ~, ~)
            % ONREMOVEROWSOK Internal function to remove deduction from
            % finance model.
            
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
                eval(sprintf("obj.Model.remove%sDeduction(splitvalue);", obj.TrackedProperty_))
            catch exception
                if strcmp(exception.identifier, "MATLAB:noSuchMethodOrField")
                    error("DeductionsController:Remove:InvalidProperty", ...
                        "Selected property does not have a remove method.")
                else
                    uialert(obj.Parent, exception.message, ...
                        sprintf("Caught Exception - %s", exception.identifier));
                end
            end
        end % onRemoveRowsOK
        
        function onRemoveEverythingOK(obj, ~, ~)
            % ONREMOVEEVERYTHINGOK Internal function to remove all
            % deductions from finance model.
            
            % Pass information to model for further processing.
            try
                eval(sprintf("obj.Model.delete%sDeductions();", obj.TrackedProperty_))
            catch exception
                if strcmp(exception.identifier, "MATLAB:noSuchMethodOrField")
                    error("DeductionsController:Remove:InvalidProperty", ...
                        "Selected property does not have a remove method.")
                else
                    uialert(obj.Parent, exception.message, ...
                        sprintf("Caught Exception - %s", exception.identifier));
                end
            end
        end % onRemoveEverythingOK
        
    end % methods (Access = ?component.window.DeductionsHandler)
    
end