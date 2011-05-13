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

  ACTIONS = %<index header footer>

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

