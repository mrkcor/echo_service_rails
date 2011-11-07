EchoService on Rails [![Build Status](https://secure.travis-ci.org/mkremer/echo_service_rails.png)](http://travis-ci.org/mkremer/echo_service_rails)
==============
Example of a basic SOAP service in Ruby on Rails, the code contains explanatory comments.

The EchoService on Rails works with Ruby 1.9.2 and 1.9.3. It will not work with JRuby because of [Nokogiri issue #494](https://github.com/tenderlove/nokogiri/issues/494)

If you have any issues, suggestions, improvements, etc. then please log them using GitHub issues.

Usage
-----
To run the EchoService on Rails simply start Rails (rails s)

The default endpoint URL in the WSDL is http://localhost:3000/echo_service, you can set the environmental variable BASE_URL to replace http://localhost:3000 with whatever is appropriate for you (per example http://echo.without-brains.net)

License
-------
EchoService on Rails is released under the MIT license.

Author
------
[Mark Kremer](https://github.com/mkremer)

