gem_coverage allows inspection of all defined gemsets and the gems in them.  Helps answer "Where do I have the 'foobar' gem installed?"

Assumes you have RVM installed in '~/.rvm'

    Usage: gemset_coverage.rb [options] [RUBY_VERSION]
           Defaults to RVM ruby version in use.
        -g, --gems gema[,gemb,gemc]      Gems to look for across gemsets
        -v, --[no-]verbose               Run verbosely

