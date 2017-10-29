YAFL
====

Yet Another Formula Language.

## Usage

TODO

### Operator priority

| operator | description |
| -------- | ----------- |
| ^ | Exponentiation |
| ! - | Not, unary minus |
| * / % | Multiply, divide, and modulo |
| + - | Addition and subtraction |
| & | Intersection |
| &#124; | Union |
| <= < > >= | Comparison operators |
| != == | Equality operators |
| && | Logical `AND` |
| &#124;&#124; | Logical `OR` |

## Installation

Add this line to your Gemfile:

```ruby
gem "yafl"
```

Or you may want to include the gem directly from GitHub:

```ruby
gem "yafl", github: "jasl-lab/yafl"
```

And then execute:

```sh
$ bundle
```

## Contributing

Bug report or pull request are welcome.

### Make a pull request

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please write unit test with your code if necessary.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
