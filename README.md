# Income Finance App

## Purpose

Use this app to compute your net income based on your recurring deductions and gross income. 
You can add pre-tax and post-tax deductions. The values of National Insurance and 
tax will be computed based on the gross income, after pre-tax and optional pension deductions have been subtracted.

## Use

To use the app, launch the App Designer file:
``` matlab
>> run FinanceApp.mlapp
```
You can set your income in the top left edit field, and then add or remove deductions from the tables in the tab group below. 
To do this, you can right-click on the tables themselves and select *"Add"* or *"Remove..."*.

The following deductions can be added to the app:

- **Pre-Tax Voluntary Deductions** - These are subtracted from the income value before the tax and National Insurance amounts are computed.
- **Pension** - The pension deduction can be optionally subtracted and is defined as a percentage of the gross income (before any subtractions are made).
- **Post-Tax Deductions** - These are any recurring deductions that you may experience with regular recurrence. 

On the other hand, the following deductions - **Pre-Tax Voluntary Deductions** - are always subtract from the gross income:

- *Tax* - Value of UK tax, computed based on gross income after Pre-Tax Voluntary Deductions and optional Pension have been subtracted.
- *National Insurance* - Value of UK National Insurance contribution, computed based on gross income.

## Data Sources

## Implementation

This app makes use of the Model-View-Controller approach (see the [Wiki page](https://en.m.wikipedia.org/wiki/Model–view–controller)) for app design.
In this case, the model is embodied by the `Finance` class, and the App Designer file `FinanceApp.mlapp` is used to combine and link the model to the 
views, controllers and the hybrid elements.

A hybrid element combines features of both views and controllers.
 
