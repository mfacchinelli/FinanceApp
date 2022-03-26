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
            
            % Add submenu to edit deduction.
            obj.Menus(1) = uimenu(obj.Main, ...
                "Text", "Edit", ...
                "MenuSelectedFcn", @obj.onEdit);
            
            % Add submenu to remove deduction.
            obj.Menus(2) = uimenu(obj.Main, ...
                "Text", "Remove...", ...
                "Separator", "on");
            
            obj.Menus(3) = uimenu(obj.Menus(2), ...
                "Text", "Selection", ...
                "MenuSelectedFcn", @obj.onRemoveSelection);
            
            obj.Menus(3) = uimenu(obj.Menus(2), ...
                "Text", "Rows", ...
                "Separator", "on", ...
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
            obj.createDialog(getRootFigure(obj), ...
                "element.window.AddDeductionHandler", ...
                "AllowedCurrencies", obj.Model.AllowedCurrencies, ...
                "AllowedRecurrence", obj.Model.AllowedRecurrence, ...
                "ParentPosition", getRootFigure(obj).Position, ...
                "OKFcn", @obj.onAddOK);
        end % onAdd
        
        function onEdit(obj, ~, ~)
            % ONEDIT Internal function to create dialog input to edit
            % selected deduction.
            
            % Retrieve views from main app.
            views = getRootFigure(obj).RunningAppInstance.Views;
            
            % Retrieve needed view.
            for v = views(:)'
                if isa(v, "element.view.DeductionsView")
                    if strcmp(v.TrackedProperty, obj.TrackedProperty_)
                        % Retrieve selected rows.
                        selectedRow = v.SelectedCells(:, 1);
                        break;
                    end
                end
            end
            
            % Check that only one row has been selected.
            if any(isnan(selectedRow)) || numel(selectedRow) ~= 1
                uialert(getRootFigure(obj), "You must select one and only one cell before using this feature.", ...
                    "Invalid Cell Selection", "Icon", "warning");
            end
            
            % Retrieve selected deduction.
            selectedDeduction = obj.Model.(obj.TrackedProperty_)(selectedRow, :);
            
            % Call UI dialog app.
            obj.createDialog(getRootFigure(obj), ...
                "element.window.AddDeductionHandler", ...
                "DefaultName", selectedDeduction.Name, ...
                "DefaultValue", selectedDeduction.Deduction, ...
                "AllowedCurrencies", obj.Model.AllowedCurrencies, ...
                "DefaultCurrency", selectedDeduction.Currency, ...
                "AllowedRecurrence", obj.Model.AllowedRecurrence, ...
                "DefaultRecurrence", selectedDeduction.Recurrence, ...
                "ParentPosition", getRootFigure(obj).Position, ...
                "OKFcn", @() obj.onEditOK(selectedRow));
        end % onEdit
        
        function onRemoveSelection(obj, ~, ~)
            % ONREMOVESELECTION Internal function to remove selected row
            % from finance model.
            
            % Retrieve views from main app.
            views = getRootFigure(obj).RunningAppInstance.Views;
            
            % Retrieve needed view.
            for v = views(:)'
                if isa(v, "element.view.DeductionsView")
                    if strcmp(v.TrackedProperty, obj.TrackedProperty_)
                        % Retrieve selected rows.
                        selectedRows = v.SelectedCells(:, 1);
                    end
                end
            end
            
            % Pass information to model for further processing.
            if ~any(isnan(selectedRows))
                obj.evalErrorHandler(sprintf("obj.Model.remove%sDeduction(selectedRows);", obj.TrackedProperty_), ...
                    "method", getRootFigure(obj));
            else
                uialert(getRootFigure(obj), "You must select at least one cell before using this feature.", ...
                    "Invalid Cell Selection", "Icon", "warning");
            end
        end % onRemoveSelection
        
        function onRemoveRows(obj, ~, ~)
            % ONREMOVEROWS Internal function to remove specific deductions
            % from finance model.
            
            % Call UI dialog app.
            obj.createDialog(getRootFigure(obj), ...
                "element.window.RemoveDeductionHandler", ...
                "ParentPosition", getRootFigure(obj).Position, ...
                "OKFcn", @obj.onRemoveRowsOK);
        end % onRemoveRows
        
        function onRemoveEverything(obj, ~, ~)
            % ONREMOVEEVERYTHING Internal function to remove all deduction
            % from finance model.
            
            % Remove all deductions.
            uiconfirm(getRootFigure(obj), ...
                "Do you wish to remove all deductions? This cannot be undone.", ...
                sprintf("Remove All %s Deductions", obj.TrackedProperty_), ...
                "Options", ["OK", "Cancel"], ...
                "Icon", "Warning", ...
                "CloseFcn", @obj.onRemoveEverythingOK);
        end % onRemoveEverything
        
        function onAddOK(obj)
            % ONADDOK Internal function to add deduction to finance model.
            
            % Retrieve edit field value.
            value = obj.Dialog.InputValue;
            
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
        
        function onEditOK(obj, selectedRow) %#ok<INUSD>
            % ONADDOK Internal function to add deduction to finance model.
            
            % Retrieve edit field value.
            value = obj.Dialog.InputValue;
            
            % Split and check value at semicolons.
            splitvalue = strip(strsplit(value, ";"));
            assert(numel(splitvalue) == 4, "DeductionsController:Dialog:WrongSize", ...
                "When adding a deduction you must specify all inputs (name, value, currency, and recurrence).")
            
            % Convert values to supported.
            splitvalue = cellfun(@string, splitvalue, "UniformOutput", false);
            splitvalue{2} = str2double(splitvalue{2}); %#ok<NASGU>
            
            % Pass information to model for further processing.
            obj.evalErrorHandler(sprintf("obj.Model.amend%sDeduction(selectedRow, splitvalue{:});", ...
                obj.TrackedProperty_), "method", getRootFigure(obj));
        end % onEditOK
        
        function onRemoveRowsOK(obj)
            % ONREMOVEROWSOK Internal function to remove deduction from
            % finance model.
            
            % Retrieve edit field value.
            value = obj.Dialog.InputValue;
            
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
        
        function onRemoveEverythingOK(obj)
            % ONREMOVEEVERYTHINGOK Internal function to remove all
            % deductions from finance model.
            
            % Pass information to model for further processing.
            obj.evalErrorHandler(sprintf("obj.Model.delete%sDeductions();", obj.TrackedProperty_), ...
                "method", getRootFigure(obj));
        end % onRemoveEverythingOK
        
    end % methods (Access = private)
    
end