function plotTaxNI()

% Load tax-NI info.
load(Finance.TaxNIFile, "TaxNIMatrix")

% Create income matrix.
income = TaxNIMatrix(:, 1);

% Create figure.
f = figure;
a = axes(f);
xlabel(a, "Income [k£]")
grid(a, "on")

yyaxis left
tax = TaxNIMatrix(:, 2)/1e3;
hold on
scatter(a, income/1e3, tax, 65)
plot(a, income/1e3, tax, "LineWidth", 1.5, "LineStyle", "--")
hold off
ylabel(a, "Tax [k£]")

yyaxis right
ni = TaxNIMatrix(:, 3)/1e3;
hold on
scatter(a, income/1e3, ni, 65)
plot(a, income/1e3, ni, "LineWidth", 1.5, "LineStyle", "-.")
hold off
ylabel(a, "NI [k£]")

end