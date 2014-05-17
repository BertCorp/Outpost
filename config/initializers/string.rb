# http://stackoverflow.com/questions/5661466/test-if-string-is-a-number-in-ruby-on-rails
class String
  def is_numeric?
    true if Float(self) rescue false
  end
end
