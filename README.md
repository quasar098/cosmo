![build](https://github.com/cosmo-lang/cosmo/actions/workflows/crystal.yml/badge.svg)
# Cosmo - Kosmo
(Kevins)Osmo
get it.. ha..

Cosmo is a statically-typed interpreted programming language written in pure Crystal.<br>
We have an [extension for VS code](https://marketplace.visualstudio.com/items?itemName=cosmo.vscode-cosmo) ([source](https://github.com/R-unic/vscode-cosmo)), however it currently only features syntax highlighting and code snippets.

## Installation

```bash
git clone https://github.com/KevinAlavik/cosmo
cd cosmo
sudo make
```

## Whats different in this fork?
Nothing much just some extra things!

## Contributing

1. [Fork it](https://github.com/R-unic/cosmo/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Test your code (`make test`)
5. Push to the branch (`make publish`)
6. Create a new [Pull Request](https://github.com/cosmo-lang/cosmo/pulls)

Have any questions or comments? DM me on Discord: `runic#5997`

## Contributors

- [R-unic](https://github.com/R-unic) - creator and maintainer
- [quasar098](https://github.com/quasar098)
- [Kevin Alavik](https://github.com/kevinalavik)

## Things I Might Do

- Named arguments
- Make a Cosmo->C compiler
- C bindings

## Things I Gotta Do

### Features
- Grammar
  - Regexes
  - Endless (and beginless?) range literals
  - Postfix `every` loop (e.x. `x < 1 for every int x in vec`)
  - `typeof`
  - Multiple assignment/declaration with spreads (e.x. `int x, y = *[1, 2]`)
  - `:=` operator (this will include making `=` binary expressions a statement [this is gonna be weird to implement lmao])
  - Enums
  - Decorators
  - Interfaces
  - Namespaces
  - Classes
    * single inheritance
    * mixins
    * static/protected members
  - Rewrite type system
    * bound expressions (!!)
    * an actual type pass
    * generics
    * type inference
    * casting union types
    * implicit conversions
    * intersection types
- Other
  - Extend `HTTP` library
  - `+` operator for vectors, same functionality as `Vector->combine`
  - `string` and `char` to hex conversions (e.x. `<uint>'f' == 15`)
  - Some form of multithreading
  - Intrinsic methods for all datatypes (inherit from a base type)
  - REPL supports multiline source

### Fixes
- Performance boosts lol
- Import stack traces
- Properly log errors from intrinsics
- Segfaults
  * passing `$`? (pretty sure this is just like everything to do with classes)
  * `<float[]>[1,2,3]`
- Class instance variables available outside of `$`
- Throw if same module was imported twice
- `["a.b.c"].first.split('.')` tries to access `["a.b.c"].first` instead of `["a.b.c"].first()` because of the `split` call with parentheses (bug)

### Tests
- Chained method calls with optional parentheses (e.x. `["a.b.c"].first.split('.').first == "a"`)
- Expectation of errors in parser spec (e.x. `()` throws `Invalid syntax ')': Expected an expression`)

### Refactorings
(empty)

TODO: http server routing stuff

### Meta
- Package manager ([Stars](https://github.com/cosmo-lang/stars) + [StarsAPI](https://github.com/cosmo-lang/stars-api)) (WIP)
- Documentation generator?
- Language server
- Highlight function definition names without parentheses

### Docs
- Explain module system in Wiki
- Update some of the screenshots on the Wiki
- Document intrinsics
