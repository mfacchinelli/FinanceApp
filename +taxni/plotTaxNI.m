function plotTaxNI()

% Load tax-NI info.
load(fullfile("cache", "taxNIInfo.mat"), "TaxNIMatrix")

% Create income matrix.
income = TaxNIMatrix(:, 1);

% Create figure.
f = figure;
a = axes(f);
xlabel(a, "Income [k£]")
grid(a, "on")

yyaxis left
tax = interp1(income, TaxNIMatrix(:, 2), income, "linear")/1e3;
hold on
scatter(a, income/1e3, tax, 65)
plot(a, income/1e3, tax, "LineWidth", 1.5, "LineStyle", "--")
hold off
ylabel(a, "Tax [k£]")

yyaxis right
ni = interp1(income, TaxNIMatrix(:, 3), income, "linear")/1e3;
hold on
scatter(a, income/1e3, ni, 65)
plot(a, income/1e3, ni, "LineWidth", 1.5, "LineStyle", "-.")
hold off
ylabel(a, "NI [k£]")

end