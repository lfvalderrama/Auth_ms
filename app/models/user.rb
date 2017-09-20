class User < ApplicationRecord
  has_secure_password
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  VALID_NAME_REGEX = /\A[^0-9`!@#\$%\^&*+_=]+\z/

  validates :email, presence: true,
                  format:     { with: VALID_EMAIL_REGEX },
                  uniqueness: { case_sensitive: false }

  validates :firstName, presence: true,
                  format:     { with: VALID_NAME_REGEX }

  validates :lastName, presence: true,
                  format:     { with: VALID_NAME_REGEX }

  before_save :downcase_email
  before_create :generate_confirmation_instructions

  def downcase_email
    self.email = self.email.delete(' ').downcase
  end

  def generate_confirmation_instructions
    self.confirmation_token = SecureRandom.hex(10)
    self.confirmation_sent_at = Time.now.utc
  end

  def confirmation_token_valid?
    (self.confirmation_sent_at + 30.days) > Time.now.utc
  end

  def mark_as_confirmed!
    self.confirmation_token = nil
    self.confirmed_at = Time.now.utc
    save
  end

  def self.valid_login?(email, password)
    user = find_by(email: email)
    if user && user.authenticate(password)
      user
    end
  end

  def allow_token_to_be_used_only_once
    regenerate_token
    touch(:token_created_at)
  end

  def logout
    invalidate_token
  end

  def self.unexpired_token(token, period)
    where(token: token).where('token_created_at >= ?', period).first
  end


  private
    # This method is not available in has_secure_token
    def invalidate_token
      update_columns(token: nil)
      touch(:token_created_at)
    end
end
