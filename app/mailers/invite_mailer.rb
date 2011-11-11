class InviteMailer < Devise::Mailer

  def guest_invitation_instructions(record)
    devise_mail(record, :guest_invitation_instructions)
  end

  def friend_invitation_instructions(record)
    devise_mail(record, :friend_invitation_instructions)
  end

end