classdef (Sealed) CurrencyController < element.Element
    
    properties
        % Parent of object.
        Parent
    end % properties
    
    properties (Access = private)
        % Dialog app to set API key.
        Dialog element.window.CurrencyAPIHandler = element.window.CurrencyAPIHandler.empty()
    end % properties (Access = private)
    
    methods
        
        function obj = CurrencyController(model, varargin)
            % Call superclass constructor.
            obj@element.Element(model)
            
            % Set properties.
            set(obj, varargin{:})
            
            % Download currency information.
            obj.downloadCurrencyInformation();
        end % constructor
        
    end % methods
    
    methods (Access = private)
        
        function downloadCurrencyInformation(obj)
            % DOWNLOADCURRENCYINFORMATION Function to load currency
            % conversion information from fixer.io.
            
            % Check for MAT file containing currency API key.
            if exist(obj.Model.CurrencyFile, "file")
                % Load API key.
                load(obj.Model.CurrencyFile, "APIKey");
                
                % Try downloading data.
                try
                    % Download conversions.
                    [EUR2GBP, USD2GBP] = currency.downloadConversions(APIKey);
                    
                    % Store values.
                    obj.Model.setCurrencyConversion(EUR2GBP, USD2GBP);
                catch exception
                    if strcmp(exception.identifier, "MATLAB:webservices:ContentTypeReaderError")
                        uialert(getRootFigure(obj.Parent), ...
                            ["Input API key is not valid. Please download the current one from: ", ...
                            "https://www.income-tax.co.uk/tax-calculator-api/"], ...
                            "Invalid API Key");
                    else
                        uialert(getRootFigure(obj.Parent), exception.message, ...
                            sprintf("Caught Exception - %s", exception.identifier));
                    end
                end
            else
                % Check that no other window is open.
                if isempty(obj.Dialog) || ~obj.Dialog.IsValid
                    % Ask user for API key and save it in MAT file.
                    obj.Dialog = element.window.CurrencyAPIHandler( ...
                        "ParentPosition", getRootFigure(obj.Parent).Position, ...
                        "OKFcn", @obj.onOK);
                else
                    uialert(getRootFigure(obj.Parent), ["A window of this kind is already open. ", ...
                        "Please finish the previous operation before starting a new one."], ...
                        "API Input Dialog Already Open", "Icon", "warning");
                end
            end
        end % downloadCurrencyInformation
        
        function onOK(obj, ~, ~)
            % ONOK Internal function to store API key to MAT file.
            
            % Retrieve value.
            APIKey = obj.Dialog.EditFieldValue;
            
            % Save value to MAT file.
            save(obj.Model.CurrencyFile, "APIKey");
            
            % Call function again (now that MAT file exists).
            obj.downloadCurrencyInformation();
        end % onOK
        
    end % methods (Access = private)
    
end