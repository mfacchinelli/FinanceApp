classdef (Abstract, Hidden) DialogHandler < matlab.mixin.SetGetExactNames
    
    properties (Access = protected)
        % Dialog app.
        Dialog element.Handler = element.Handler.empty()
    end % properties (Access = protected)
    
    methods
        
        function delete(obj)
            if isvalid(obj.Dialog)
                obj.Dialog.delete();
            end
        end % destructor
        
    end % methods
    
    methods (Access = protected)
        
        function createDialog(obj, rootFigure, dialogClass, varargin)
            % CREATEDIALOG Internal function to create dialog input.
            
            % Check that no other window is open.
            if isempty(obj.Dialog) || ~isvalid(obj.Dialog) || ~obj.Dialog.IsValid
                % Call UI dialog app.
                try
                    obj.Dialog = eval(sprintf("%s(varargin{:});", dialogClass));
                catch exception
                    if strcmp(exception.identifier, "MATLAB:undefinedVarOrClass")
                        error("DialogHandler:Creation:InvalidWindow", ...
                            "Selected window type does not exist.")
                    else
                        uialert(getRootFigure(obj), eraseTags(exception.message), ...
                            sprintf("Caught Exception - %s", exception.identifier));
                    end
                end
            else
                uialert(rootFigure, ["A window of this kind is already open. ", ...
                    "Please finish the previous operation before starting a new one."], ...
                    "Input Dialog Already Open", "Icon", "warning");
            end
        end % createDialog
        
    end % methods (Access = protected)
    
end