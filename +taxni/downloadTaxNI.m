function [taxNIMatrix, updateDate] = downloadTaxNI(APIKey, income)
% DOWNLOADTAXNI Download monthly tax and NI details based on gross yearly
% income, by using income-tax.co.uk APIs. The API key needs to be refreshed
% daily and retrieved (manually) from:
% https://www.income-tax.co.uk/tax-calculator-api/

% Check arguments validity.
arguments
    APIKey (1, 1) string
    income (1, :) double
end

% Define API URL.
url = sprintf("https://www.income-tax.co.uk/api/%s/%%d/", APIKey);

% Pre-allocate output.
taxNIMatrix = zeros(numel(income), 3);

% Create 'weboptions' object.
options = weboptions("Timeout", 5, "CharacterEncoding", "UTF-8", "ContentType", "json");

% Loop over income values.
for i = 1:numel(income)
    % Connect to website.
    result = webread(sprintf(url, income(i)), options);
    
    % Store results.
    if ~isempty(result)
        taxNIMatrix(i, :) = [income(i), ...
            str2double(result.tax.yearly), ...
            str2double(result.ni.yearly)];
    else
        taxNIMatrix(i, :) = zeros(1, 3);
    end
end

% Set last update date.
updateDate = datetime("today");

end