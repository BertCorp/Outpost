module ApplicationHelper
  
  def get_host(url)
    url = "http://#{url}" unless url.start_with?('http')
    uri = URI.parse(url)
    uri.host.downcase
  end
  
  def htmlify(s)
    return simple_format(urlify(s)) if s.present?
    ''
  end
  
  def urlify(s)
    s.gsub(%r{\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/)))}u) do |s|
      %Q{<a href="#{s}">#{s}</a>}
    end.html_safe
  end
  
end
