gem_coverage allows inspection of all defined gemsets and the gems in them.  Helps answer "Where do I have the 'foobar' gem installed?"

Assumes you have RVM installed in '~/.rvm'

    Usage: gemset_coverage.rb [options] [RUBY_VERSION]
           RUBY_VERSION defaults to current RVM ruby version in use.
           Either '--all_gems' or '--gems' option is required.
        -g, --gems gema[,gemb,gemc]      Gems to look for across gemsets
        -a, --all_gems                   Display all installed gems across all gemsets
        -v, --[no-]verbose               Run verbosely, display inspected gemsets

