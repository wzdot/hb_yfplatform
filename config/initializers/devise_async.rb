module Devise
  module Models
    module Confirmable
      # Send confirmation instructions by email
      def send_confirmation_instructions
        generate_confirmation_token! if self.confirmation_token.nil?
        ::Devise.mailer.delay.confirmation_instructions(self)
      end
    end

    module Recoverable
      # Resets reset password token and send reset password instructions by email
      def send_reset_password_instructions
        generate_reset_password_token!
        ::Devise.mailer.delay.reset_password_instructions(self)
      end
    end

    module Lockable
      # Send unlock instructions by email
      def send_unlock_instructions
        ::Devise.mailer.delay.unlock_instructions(self)
      end
    end
  end
end