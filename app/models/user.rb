class User < ActiveRecord::Base
  
  belongs_to :company
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def is_admin?
    ['zack@outpostqa.com', 'mark@outpostqa.com', 'admin@outpostqa.com'].include? email
  end

end
