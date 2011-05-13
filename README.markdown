Rack Side Include
=================

Description
-----------

Rack::RSI is an rack middleware which helps you assemble pages on
similar lines of ESI without leaving the comfort of Ruby. Rack Side
Include only support one feature of ESI i.e. &lt;esi:include&gt;. One of
the key differentiator from esi standard it uses ERB rather than XML
tags to assemble pages and it does not assemble pages outside the
Application.

Rationale
---------

A fair bit of what ESI offers, is in the ESI language because Akamais
customers cannot configure the Akamai edge proxies. While this is
perfectly sensible for the Akamai business model, it is of little
relevance for WebApps where the content-provider is in control of the
servers.

Also if you do not want to use a separate tier for ESI, the ESI standard
is too heavy to implement as a Rack Middleware.

ERB is much simpler to render and less CPU intensive interms of XML
parsing and generating response.

Assembling pages inside the applications is chosen deliberately because
the content for assembly is fetched from within the Rack stack without
firing any HTTP requests to the server.

Potential Scenarios
-------------------

#### Pages Decorated with Short Lived Information

Consider a case of high volume news website. Most pages on this website
contains one article decorated by ads and a "hot news" box. Without the
assembly the TTL for each of these articles need to be kept low, to keep
decorations and in particular "hot news" box fresh.

Rack Server Include assembly middleware allows you to break the page
into different fragments which can be cached differently and are
assembled just before serving the request to the client. In above case
article can be cached for an infinitely long time, with a directive to
tell the middle where what and where to include the "hot news" box from.

Each part of the section and the page containing the rack side include
directive can be cached differently.

#### Creating Dashboards

Consider an admin dashboard of an ecommerce website which shows the new
orders and new products added on the system.

If we are not using assembly middleware you would require to populate
relevant order and product object in dashboard controller which is not
well organized. Ideally orders controller should fetch order objects and
products controller should fetch the products.

Rack Server Include assembly lets you achieve this by calling two
include directives. One to new orders and one to new products which will
be served by orders and products controller respectively.

This can really help you keep you application slim and well-organized.

How do I use in Rails 3
-----------------------

in Gemfile

    gem 'rack-rsi'

in config/application.rb

    # Rack::RSI should be loaded high up the Rack Middleware Stack
    config.middleware.insert_after Rack::Runtime, Rack::RSI

in controller action

    def foo_action
      # Notify Rack::RSI to process this request
      headers['rack.rsi'] = '1'
      ...
    end

in view template foo_action.html.erb

    ...
    <%%= rsi_include( '/path/to_include' ) %>
    ...

Limitations
------------

* Only GET requests are supported as rack side includes

License
-------

Copyright &copy; 2011 Ram Singla. Released under MIT License.
