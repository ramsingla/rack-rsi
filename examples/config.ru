require "pathname"

$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname)
$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname.parent.join("lib"))

require "rack/rsi"
require "hello_world_app"

use Rack::ShowExceptions
use Rack::Runtime
use Rack::RSI
use Rack::CommonLogger
run HelloWorldApp.new
