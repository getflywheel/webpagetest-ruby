source 'https://rubygems.org'

# Specify your gem's dependencies in webpagetest.gemspec
gemspec

# Faraday 2.x removed :basic_auth from core, which this gem's supported usage
# pattern depends on (see README "Known Issues"). Pinned here (dev/test only,
# not the gemspec) so CI reflects the version actually used in production.
gem "faraday", "~> 1.0"
