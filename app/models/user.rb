class User < ActiveRecord::Base
  include Accounts::IsAUser

  rolify

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :time_zone, :drc_uid

  has_many :owned_businesses, :foreign_key => :owner_id, :class_name => 'Business'
  has_and_belongs_to_many :businesses, :join_table => 'businesses_users'

  class << self
    def current_user=(user)
      Thread.current[:current_user] = user
    end

    def current_user
      Thread.current[:current_user]
    end

    def find_for_cas_oauth(access_token, signed_in_resource=nil)
      data = access_token.extra

      if signed_in_resource
        signed_in_resource.update_attribute(:drc_uid, data.user)
        signed_in_resource
      elsif user = User.where(:drc_uid => data.user).first
        user
      elsif user = User.where(:email => data.user + "@metododerose.org").first
        user.update_attribute(:drc_uid, data.user)
        user
      else # Create a user with a stub password.
        User.create!(:drc_uid => data.user, :email => data.user + "@metododerose.org", :password => Devise.friendly_token[0,20])
      end
    end
  end

  def username
    self.drc_uid
  end

end
