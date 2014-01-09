class TestSuite < ActiveRecord::Base
  
  belongs_to :company
  has_many :test_cases, dependent: :destroy
  has_many :reports, dependent: :destroy
  #Attributes: title, description, setup_video_url, production_url, staging_url
  
  
end
