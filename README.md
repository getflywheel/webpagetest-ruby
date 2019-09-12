# Webpagetest Ruby Wrapper
This is a fork of the webpagetest-ruby gem, as it has not been maintained since 2015. It adds:
- support for basic auth
- enforces HTTPS requests with self-signed certs (it could be nice to add full SSL support at a later date, but for the current use, we don't need it)


This gem is a Ruby wrapper for the main features of [Webpagetest](http://www.webpagetest.org/) REST API.
Features included on the original gem (as of 2015):
- Run tests with all [specified](https://sites.google.com/a/webpagetest.org/docs/advanced-features/webpagetest-restful-apis#TOC-Parameters) parameters of the API.
- Check test status
- Get available test locations

This gem is inspired by [Susuwatari](https://github.com/moviepilot/susuwatari) gem, so several ideas were taken from there (it's like a rewrite with some modifications).


## Installation

Add this line to your application's Gemfile:

    gem 'webpagetest'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webpagetest

## Usage
To run a test off of the public WebPageTest instance, all you require is an API key. You can ask for your own by emailing Patrick Meenan, like he explains in [Webpagetest docs](https://sites.google.com/a/webpagetest.org/docs/advanced-features/webpagetest-restful-apis).

To run a test off of the Flywheel private WebPageTest instance, you will need to use the API key assigned to our instance as well as a username and password for our instance. All Flywheel devs should have access to these in the Flywheel 1Pass vault.

Then you need to instantiate an object of the `Webpagetest` class and use it to interact with the API.

### Set up connection options for request

```ruby
connection_options = { 
  request: :basic_auth,
  response: :logger,
  adapter: :net_http,
  url: flywheels_private_webpagetest_instance,
  user: your_username,
  pass: your_password
}
```

### Instantiate WPT object

```ruby
require 'webpagetest'

wpt = Webpagetest.new(k: your_api_key, options: connection_options)
```

### Run test
When running a test, a `Response` object is returned, with the following available methods:

* `test_id`: the `id` assigned to the submitted test
* `status`: the status of the test (`nil` at the beginning)
* `result`: the result object (`nil` at the beginning)
* `raw`: the raw response of the request
* `get_status`: makes a test status request, and fetches the result when status is `:completed`

```ruby
response = wpt.run_test do |params|
    params.url = 'http://webpagetest.org' # The url to test
end

# Test is running, so status must be requested
response.get_status # => :running

# When test is completed, status will be updated
response.get_status # => :completed

# Only after knowing that test is completed, the result is set
response.result.keys
[
    [ 0] "id",
    [ 1] "url",
    [ 2] "summary",
    [ 3] "testUrl",
    [ 4] "location",
    [ 5] "from",
    [ 6] "connectivity",
    [ 7] "bwDown",
    [ 8] "bwUp",
    [ 9] "latency",
    [10] "plr",
    [11] "completed",
    [12] "testerDNS",
    [13] "runs",
    [14] "fvonly",
    [15] "successfulFVRuns",
    [16] "successfulRVRuns",
    [17] "average",
    [18] "standardDeviation",
    [19] "median",
    [20] "status_code",
    [21] "status_text"
]

response.result.runs[1].firstView.loadTime # => 2051
```

### Get test result
In order to get a result based on a test `id`,  the same procedure as above must be done.
```ruby
test = wpt.test_result("some_test_id") # test is a Response object

response.test_id # => "131007_FC_WHR"

# Test could be running or completed
response.get_status # => :completed

response.result.average.firstView.domElements # => 714
```

### Locations
```ruby
locations = wpt.locations
locations.keys
[
    [  0] "Dulles_IE6",
    [  1] "Dulles_IE10",
    [  2] "Dulles:Chrome",
    [  3] "Dulles:Canary",
    [  4] "Dulles:Firefox",
    [  5] "Dulles_iOS",
    [  6] "Dulles_Android",
    [  7] "Dulles_Thinkpad:Chrome",
    [  8] "Dulles_Thinkpad:Canary",
    [  9] "Asheville_IE",
    [ 10] "Miami_IE8",
    [ 11] "Miami:Chrome",
    [ 12] "Miami:Firefox",
    ...
]
```

## Contribution
This gem is just a starting point wrapper, so much work can be done from here.

Any contribution is appreciated. Just fork this repository and submit the appropriate pull request if you want to add features to this gem.
