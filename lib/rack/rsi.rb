# Copyright Ram Singla (c) 2011.
# Released under MIT License

require 'rack'
require 'erb'
require 'uri'
require 'digest/md5'
require 'rack/rsi_version'

class Rack::RSI

  class Error < ::RuntimeError
  end

  class RsiRender

    def initialize( app, env, level = 1 )
      @app, @env, @level = app, env, level
      @headers, @body = {}, {}
    end

    def rack_rsi?
      @headers.values.select{ |x| x && x['rack.rsi'] }.any?
    end

    def cache_control_headers
      @headers.values.collect{ |x| ( x ? x['Cache-Control'] : nil ) || 'max-age=0' }
    end

    def get_binding
      return binding( )
    end

    def rsi_include( source, raise_on_error = false )
      return "" unless @level < 5
      uri = URI.parse( source )
      include_env = @env.merge( "PATH_INFO" => uri.path,
                               "SCRIPT_NAME" => "",
                               "QUERY_STRING" => uri.query,
                               "REQUEST_METHOD" => "GET" )
      begin
        include_status, include_headers, include_body = @app.dup.call(include_env)
        @headers[ source ] = include_headers
        @body[ source ] = ( include_status == 200 ? include_body : [] )
      rescue Exception => message
        raise message if raise_on_error
        @body[ source ] = []
      end
      value = ''
      @body[ source ].each{ |part| value << part }
      value
    end

  end

  def initialize( app )
    @app = app
  end

  def call( env )
    assemble_response( env )
  end

  # Assemble Response
  def assemble_response( env )
    vanilla_env = env.dup
    vanilla_app = @app.dup

    # calling app and env on orignal request
    status, headers, enumerable_body = original_response = @app.call(env)

    rack_rsi_flag = headers.delete('rack.rsi')

    # Assemble Pages if rack_rsi_flag is set and status is 200 ok
    # otherwise return the original response
    return original_response unless rack_rsi_flag && status == 200

    body = ""
    enumerable_body.each do |part|
      body << part
    end

    cache_control_headers = Array( headers.delete( 'Cache-Control' ) || "max-age=0" )

    # Like Varnish supports upto 5 levels of ESI includes recursively
    level = 1
    while( rack_rsi_flag )
      erb = ERB.new( body, 0 )
      renderer = RsiRender.new( vanilla_app, vanilla_env, level )
      body = erb.result( renderer.get_binding )
      renderer.cache_control_headers.inject( cache_control_headers ){ |s,x| s.push( x ) }
      rack_rsi_flag = renderer.rack_rsi?
      level += 1
    end

    # Set ETag for the Request
    headers['ETag'] = Digest::MD5.hexdigest( body )
    headers.delete( 'Last-Modified' )

    # For Assembled Pages Cache-Control to be set as private, with
    # max-age=<minimum max-age of all the requests that are assembled>
    # and should be revalidate on stale. If max-age is not set for even one of the
    # requests then max-age is set to 0.
    min_max_age = cache_control_headers.collect{ |x| x.match(/max-age\s*=\s*(\d+)/).to_a[1].to_i }.min

    headers['Cache-Control'] = "private, max-age=#{min_max_age}, must-revalidate"
    headers.delete( 'Expires' )
    headers['Expires'] = ( Time.now.utc + min_max_age ).strftime("%a, %d %m %Y %T %Z") if min_max_age > 0

    # Create Correct Content-Length
    headers['Content-Length'] = Rack::Utils.bytesize( body ).to_s

    # For now whatever headers is set by the original action would be
    # passed on. Except for Cache-Control, ETag, Expires, Last-Modified
    # Cookies from the original action are passed on.
    [ status, headers, [ body ] ]
  end

end

