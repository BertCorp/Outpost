class TestSuite < ActiveRecord::Base
  
  belongs_to :company
  has_many :test_cases
  has_many :reports
  #Attributes: title, description, setup_video_url, production_url, staging_url
  
  
end
