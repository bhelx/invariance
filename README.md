# Invariance

This is an experiment with [Design by Contract](https://en.wikipedia.org/wiki/Design_by_contract) programming in Ruby.
It's not intended for real-world use, it's just for experimenting with property based testing.

## Example

```ruby

class MyClass
  extend Invariance::Methods

  # Contract
  types [Integer, Integer] => Integer
  pre 0, ->(i){i >= 0}
  pre 1, ->(i){i >= 0}
  post do |result, args|
    result >= args.first \
    && result >= args.last
  end
  # Method
  def add(a, b)
    a + b
  end
end
```

