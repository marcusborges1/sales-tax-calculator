# Sales Tax Calculator

A simple sales tax calculator that implements [this challenge](https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36). Check it for more details and more examples of input and output.

## Requirements:

This software should be able to read inputs following this format:

```
1 imported bottle of perfume at 27.99
1 bottle of perfume at 18.99
1 packet of headache pills at 9.75
3 imported boxes of chocolates at 11.25
```

After reading this input, it must be able to generate the receipt with sales tax calculation below:

```
1 imported bottle of perfume: 32.19
1 bottle of perfume: 20.89
1 packet of headache pills: 9.75
3 imported boxes of chocolates: 35.55
Sales Taxes: 7.90
Total: 98.38
```

The tax calculation rules are the following:
  - Basic sales tax is applicable at a rate of 10% on all goods, except books, food, and medical products that are exempt.
  - Import duty is an additional sales tax applicable on all imported goods at a rate of 5%, with no exemptions.
  - The rounding rules for sales tax are that for a tax rate of n%, a shelf price of p contains (np/100 rounded up to the nearest 0.05) amount of sales tax.

## Implementation

### Assumptions and limitations

- Current implementation assumes that imported products will have text "imported" as part of its description.
- Since the purpose of this challenge is to be solved in 4 hours, I chose not to go with an robust approach using a proper product catalog or even NLP to categorize the products as books, food, medical products or other. Instead, I chose a very simple approach that is based on predefined words to categorize them.
    - Of course this is not the best approach for a production environment, but it seems good enough to the purposes of this challenge.
    - The obvious limitation here, is that we can only calculate properly the taxes of products whose words we already know up-front.
- One last limitation is that we only calculate sales taxes for inputs that are completly valid. Otherwise, the program will give feedback indicating the occured error and finishing its execution.

### Project structure

Project structure is as simple as our challenge requires it to be.

- **main.rb**: Entry point for the application.
- **lib/**: Core business logic classes.
- **spec/**: Rspec test suite with unit, integration, and end-to-end tests.
- **fixtures/**: Sample input files for testing different scenarios.
- **Rakefile**: Task automation for common development workflows.

### Core classes

This application follows object-oriented design with clear separation of concerns. Core classes listed below:

- **InputParser**: Parses input files into LineItem objects
- **LineItem**: Value object representing a product with automatic categorization
- **TaxCalculator**: Calculates sales tax and import duties
- **Receipt**: Orchestrates the receipt generation process (through composition)
- **SalesTaxReport**: Formats and displays the final receipt

### Design and stack decisions

Decisions to make the project viable.

- **Composition over inheritance**: Receipt composes TaxCalculator for extensibility.
- **Immutability and thread safety**: Objects use `freeze` and `attr_reader` for thread safety. Also there is no shared mutable state.
- **BigDecimal**: Precise decimal arithmetic for financial calculations
- **Dependency injection**: Easy testing and extensibility
- **Automated tests**: Unit, integration and end-to-end test cases using RSpec.
- **Static code analyzing**: Maintaining the standard among the codebase using Rubocop.
- **Continuous Integration**: Simple CI that runs lint and tests to make sure codebase is running as expected.

## Setup

### Prerequisites
- [Ruby 3.4.7](https://www.ruby-lang.org/)
- [Bundler](https://bundler.io/) (available by default on ruby 3.4.7)

### Installation

Install dependencies:
```shell
bundle install
```

### Development

This project uses rake to make it simple to run common development tasks:

```shell
rake spec                   # Run tests
rake rubocop                # Check code style
rake rubocop:autocorrect    # Auto-fix style issues
rake check                  # Run all checks
```

## How to run

Run with one of the provided fixture files:

```
ruby main.rb fixtures/basic_items.txt
ruby main.rb fixtures/imported_items.txt
ruby main.rb fixtures/mixed_items.txt
```

Or provide your own input file:
```
ruby main.rb path/to/your/input.txt
```

If no file is specified, it defaults to `fixtures/basic_items.txt`.

## Evidence this solution works

This codebase has e2e test that uses Open3 from ruby standard library to provides methods to execute external commands as subprocesses. Basically, it runs the application exactly as a user would from command line.

The end-to-end tests uses fixtures from the challenge specification. The test expectations match the specification outputs, so if CI passes (tests + linter), the solution works as expected. The badge below shows the current CI status:

[![CI](https://github.com/marcusborges1/sales-tax-calculator/actions/workflows/ci.yml/badge.svg)](https://github.com/marcusborges1/sales-tax-calculator/actions/workflows/ci.yml)