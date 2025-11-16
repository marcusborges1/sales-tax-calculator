# Sales Tax Calculator

A simple sales tax calculator that implements [this challenge](https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36).

More documentation soon.

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

This project uses rake for running make it simple to run common development tasks:

```shell
rake spec                   # Run tests
rake rubocop                # Check code style
rake rubocop:autocorrect    # Auto-fix style issues
rake check                  # Run all checks
```