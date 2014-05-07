# Allow exceptions to be ignored
# Source: http://avdi.org/talks/rockymtnruby-2011/things-you-didnt-know-about-exceptions.html
class Exception
  attr_accessor :continuation
  def ignore
    continuation.call
  end
end

require 'continuation' # Ruby 1.9
module RaiseWithIgnore
  def raise(*args)
    callcc do |continuation|
      begin
        super
      rescue Exception => e
        e.continuation = continuation
        super(e)
      end
    end
  end
end

class Object
  include RaiseWithIgnore
end
