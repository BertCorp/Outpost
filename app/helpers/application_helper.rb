module ApplicationHelper
  
  def urlify(s)
    s.gsub(%r{\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))}u) do |s|
      %Q{<a href="#{s}">#{s}</a>}
    end.html_safe
  end
  
end
