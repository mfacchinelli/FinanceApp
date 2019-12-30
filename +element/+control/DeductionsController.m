classdef (Sealed) DeductionsController < element.Component & element.DialogHandler
    
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
        % Internal value of the tracked property of the model.
        TrackedProperty_ string = string.empty()
    end % properties (Access = private)
    
    methods
        
        function obj = DeductionsController(model, varargin)
            % Call superclass constructor.
            obj@element.Component(model)
            
            % Create button group.
            % Main - Context menu for submenus.
            obj.Main = uicontextmenu("Parent", []);
            
            % Add submenu to add deduction.
            obj.Menus(1) = uimenu(obj.Main, ...
                "Text", "Add", ...
                "MenuSelectedFcn", @obj.onAdd);
            
            % Add submenu to remove deduction.
            obj.Menus(2) = uimenu(obj.Main, ...
                "Text", "Remove...");
            
            obj.Menus(3) = uimenu(obj.Menus(2), ...
                "Text", "Rows", ...
                "MenuSelectedFcn", @obj.onRemoveRows);
            
            obj.Menus(4) = uimenu(obj.Menus(2), ...
                "Text", "Everything", ...
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
            
            % Call UI dialog app.
            obj.createDialog(getRootFigure(obj.Parent), ...
                "element.window.DeductionsHandler", ...
                "Mode", "add", ...
                "ParentPosition", getRootFigure(obj).Position, ...
                "OKFcn", @obj.onAddOK);
        end % onAdd
        
        function onRemoveRows(obj, ~, ~)
            % ONREMOVEROWS Internal function to remove specific deductions
            % from finance model.
            
            % Call UI dialog app.
            obj.createDialog(getRootFigure(obj.Parent), ...
                "element.window.DeductionsHandler", ...
                "Mode", "remove", ...
                "ParentPosition", getRootFigure(obj).Position, ...
                "OKFcn", @obj.onRemoveRowsOK);
        end % onRemoveRows
        
        function onRemoveEverything(obj, ~, ~)
            % ONREMOVEEVERYTHING Internal function to remove all deduction
            % from finance model.
            
            % Remove all deductions.
            uiconfirm(getRootFigure(obj.Parent), ...
                "Do you wish to remove all deductions? This cannot be undone.", ...
                sprintf("Remove All %s Deductions", obj.TrackedProperty_), ...
                "Options", ["OK", "Cancel"], ...
                "Icon", "Warning", ...
                "CloseFcn", @obj.onRemoveEverythingOK);
        end % onRemoveEverything
        
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
            obj.evalErrorHandler(sprintf("obj.Model.add%sDeduction(splitvalue{:});", obj.TrackedProperty_), ...
                "method", getRootFigure(obj));
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
            obj.evalErrorHandler(sprintf("obj.Model.remove%sDeduction(splitvalue);", obj.TrackedProperty_), ...
                "method", getRootFigure(obj));
        end % onRemoveRowsOK
        
        function onRemoveEverythingOK(obj, ~, ~)
            % ONREMOVEEVERYTHINGOK Internal function to remove all
            % deductions from finance model.
            
            % Pass information to model for further processing.
            obj.evalErrorHandler(sprintf("obj.Model.delete%sDeductions();", obj.TrackedProperty_), ...
                "method", getRootFigure(obj));
        end % onRemoveEverythingOK
        
    end % methods (Access = private)
    
end