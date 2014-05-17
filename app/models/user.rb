class User < ActiveRecord::Base
  
  belongs_to :company
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :ensure_authentication_token

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
  
  def is_admin?
    ['zack@outpostqa.com', 'mark@outpostqa.com', 'admin@outpostqa.com'].include? email
  end


  private

  def generate_authentication_token
    loop do
      token = "u_#{Devise.friendly_token}"
      break token unless User.where(authentication_token: token).first
    end
  end

end
