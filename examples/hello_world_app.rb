require "rack"

class HelloWorldApp

  def call(env)
    request  = Rack::Request.new(env)
    response = Rack::Response.new

    if request.path_info == "/"
      action = "index"
    else
      action = request.path_info[1..-1].gsub(/\?.*$/, '')
    end

    if ACTIONS.include?(action)
      send(action, request, response)
    else
      response.status = 404
      response.write("404 Not Found")
    end

    response.finish
  end

  private

  ACTIONS = %<index header footer recursive error noerror>

  # Output /error
  # Raises Exception
  def error(request, response)
    response['rack.rsi'] = '1'
    response['Cache-Control'] = 'max-age=10'
    # depth if set as a param will be string rather than integer
    # depth + 1 in line 36 should raise error on recursive call
    depth = request.params['depth'] || 1
    response.write(%{
      <%= rsi_include( "/error?depth=#{depth+1}", :raise_on_error ) %>
      <p>Hello World! #{depth}</p>
    }.gsub(/^\s*/, "").strip)
  end

  # Output /noerror
  # Hello World! 1
  def noerror(request, response)
    response['rack.rsi'] = '1'
    response['Cache-Control'] = 'max-age=10'
    # depth if set as a param will be string rather than integer
    # depth + 1 in line 36 should raise error on recursive call
    # which is silently ignore
    depth = request.params['depth'] || 1
    response.write(%{
      <%= rsi_include( "/error?depth=#{depth+1}" ) %>
      <p>Hello World! #{depth}</p>
    }.gsub(/^\s*/, "").strip)
  end

  # Output /recursive
  # Hello World! 5
  #
  # Hello World! 4
  #
  # Hello World! 3
  #
  # Hello World! 2
  #
  # Hello World! 1
  def recursive(request, response)
    response['rack.rsi'] = '1'
    response['Cache-Control'] = 'max-age=10'
    depth = ( request.params['depth'] || 1 ).to_i
    response.write(%{
      <%= rsi_include( "/recursive?depth=#{depth+1}", :raise_on_error ) %>
      <p>Hello World! #{depth}</p>
    }.gsub(/^\s*/, "").strip)
  end

  # Output /
  # Here comes header from Header Action exclusively for buzzmenot
  #
  # Hello World!
  #
  # Here comes footer from Footer Action exclusively for github
  #
  def index(request, response)
    response['rack.rsi'] = '1'
    response['Cache-Control'] = 'max-age=3600'
    response.write(%{
      <title>HelloWorld</title>
      <%= rsi_include( "/header?user=buzzmenot" ) %>
      <p>Hello World!</p>
      <%= rsi_include( "/footer?company=github" ) %>
    }.gsub(/^\s*/, "").strip)
  end

  def header(request, response)
    response['Cache-Control'] = 'max-age=60'
    response.write( "Here comes header from Header Action exclusively for #{request.params['user']}" )
  end

  def footer(request, response)
    response['Cache-Control'] = 'max-age=120'
    response.write( "Here comes footer from Footer Action exclusively for #{request.params['company']}" )
  end

end

