function [EUR2GBP, USD2GBP, updateDate] = downloadConversions(APIKey)
% DOWNLOADCONVERSIONS Download currency conversion information based for
% supported currencies, by using fixer.io APIs. The API key needs to be 
% accessed with a free account for:
% https://fixer.io

% Check arguments validity.
arguments
    APIKey (1, 1) string
end

% Define API URL.
url = sprintf("http://data.fixer.io/api/latest?access_key=%s&symbols=GBP,EUR,USD", APIKey);

% Create 'weboptions' object.
options = weboptions("Timeout", 5, "CharacterEncoding", "UTF-8", "ContentType", "json");

% Connect to website.
result = webread(url, options);

% Determine conversions w.r.t. GBP.
switch result.base 
    case "GBP"
        % Values are already converted.
        EUR2GBP = result.rates.EUR;
        USD2GBP = result.rates.USD;
    case "EUR"
        % Convert value to GBP.
        EUR2GBP = result.rates.GBP / result.rates.EUR;
        USD2GBP = result.rates.EUR / result.rates.USD * result.rates.GBP;
    case "USD"
        % Convert value to GBP.
        EUR2GBP = result.rates.USD / result.rates.EUR * result.rates.GBP;
        USD2GBP = result.rates.GBP / result.rates.USD;
end

% Set last update date.
updateDate = datetime(result.date, "InputFormat", "yyyy-MM-dd");

end