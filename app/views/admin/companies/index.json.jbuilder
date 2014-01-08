json.array!(@companies) do |company|
  json.extract! company :created_at, :updated_at
  json.url company_url(company, format: :json)
end
