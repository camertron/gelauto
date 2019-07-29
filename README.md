## gelauto [![Build Status](https://travis-ci.com/camertron/gelauto.svg?branch=master)](https://travis-ci.com/camertron/gelauto)

Automatically annotate your code with Sorbet type definitions.

## What is This Thing?

The wonderful folks at Stripe recently released a static type checker for Ruby called [Sorbet](https://github.com/sorbet/sorbet). It works by examining type signatures placed at the beginning of each method. For example:

```ruby
# typed: true

class Car
  extend T::Sig

  sig { params(num_wheels: Integer) }
  def initialize(num_wheels)
    @num_wheels = num_wheels
  end

  sig { params(speed: Float).returns(T::Boolean) }
  def drive(speed)
    true
  end
end
```

Adding these definitions means you get cool stuff like auto-complete and type checking in your editor. Pretty freaking rad.

### Ok, so what is Gelauto?

Gelauto is an _auto_-matic way (get it?! lol) of adding Sorbet type signatures to your methods. It works by running your code (for example, your test suite). As your code runs, Gelauto keeps track of the actual types of objects that were passed to your methods as well as the types of objects they return. After gathering the info, Gelauto then (optionally) inserts type signatures into your Ruby files.

## Installation

`gem install gelauto`

## Usage

You can run Gelauto either via the command line or by adding it to your bundle.

### Command Line Usage

First, install the gem by running `gem install gelauto`. That will make the `gelauto` executable available on your system.

Gelauto's only subcommand is `run`, which accepts a list of Ruby files to scan for methods and a command to run that will exercise your code.

In this example, we're going to be running an [RSpec](https://github.com/rspec/rspec) test suite.
Like most RSpec test suites, let's assume ours is stored in the `spec/` directory (that's the RSpec default too). Let's furthermore assume our code is stored in the `lib` directory. To run the test suite in `spec/` and add type definitions to our files in `lib/`, we might run the following command:

```bash
gelauto run --annotate $(find . -name '*.rb') -- bundle exec rspec spec/
```

You can also choose to run Gelauto with the `--rbi` flag, which will cause Gelauto to print results to standard output in [RBI format](https://sorbet.org/docs/rbi).

In this second example, we're going to be running a minitest test suite. Like most minitest suites, let's assume ours is stored in the `test/` directory (that's the Rails default too). To run the test suite in `test/`, we might run the following command:

```bash
gelauto run --annotate $(find . -name '*.rb') -- bundle exec rake test/
```

### Gelauto in your Bundle

If you would rather run Gelauto as part of your bundle, add it to your Gemfile like so:

```ruby
gem 'gelauto'
```

Gelauto can be invoked from within your code in one of several ways.

#### Gelauto.discover

Wrap code you'd like to run with Gelauto in `Gelauto.discover`:

```ruby
require 'gelauto'

Gelauto.paths << 'path/to/file/i/want/to/annotate.rb'

Gelauto.discover do
  call_some_method(with, some, params)
end

# loop over files and annotate them
Gelauto.each_absolute_path do |path|
  Gelauto.annotate_file(path)
end

# you can also grab a reference to the method cache Gelauto
# has populated with all the type information it's been able
# to gather:
Gelauto.method_index
```

#### Setup and Teardown

`Gelauto.discover` is just syntactic sugar around two methods that start and stop Gelauto's method tracing functionality:

```ruby
Gelauto.setup

begin
  call_some_method(with, some, params)
ensure
  Gelauto.teardown
end
```

#### RSpec Helper

Gelauto comes with a handy RSpec helper that can do most of this for you. Simply add

```ruby
require 'gelauto/rspec'
```

to your spec_helper.rb, Rakefile, or wherever RSpec is configured. You'll also need to set the `GELAUTO_FILES` environment variable when running your test suite. For example:

```bash
GELAUTO_FILES=$(find ./lib -name *.rb) bundle exec rspec
```

Files can be separated by spaces, newlines, or commas. Finally, if you want Gelauto to annotate them, set `GELAUTO_ANNOTATE` to `true`, eg:

```bash
GELAUTO_FILES=$(find ./lib -name *.rb) GELAUTO_ANNOTATE=true bundle exec rspec
```

## How does it Work?

Gelauto makes use of Ruby's [TracePoint API](https://ruby-doc.org/core-2.6/TracePoint.html). TracePoint effectively allows Gelauto to receive a notification whenever a Ruby method is called and whenever a method returns. That info combined with method location information gathered from parsing your Ruby files ahead of time allows Gelauto to know a) where methods are located, 2) what arguments they take, 3) the types of those arguments, and 4) the type of the return value.

"Doesn't that potentially make my code run slower?" is a question you might ask. Yes. Gelauto adds overhead to literally every Ruby method call, so your code will probably run quite a bit slower. For that reason you probably won't want to enable Gelauto in, for example, a production web application.

## Known Limitations

* Half-baked support for singleton (i.e. static) methods.
* Gelauto does not annotate Ruby files with `# typed: true` comments or `extend T::Sig`.
* Gelauto ignores existing type signatures and will simply add another one right above the method.

## Running Tests

`bundle exec rspec` should do the trick :)

## Contributing

Please fork this repo and submit a pull request.

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* Cameron C. Dutro: http://github.com/camertron
