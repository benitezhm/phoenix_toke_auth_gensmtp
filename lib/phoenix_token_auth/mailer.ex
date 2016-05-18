defmodule PhoenixTokenAuth.Mailer do
  require Logger

  @moduledoc """
  Responsible for sending mails.
  Configuration options:

      config :phoenix_token_auth,
        email_sender: "myapp@example.com",
        mailgun_domain: "example.com",
        mail_relay: "smtp.gmail.com",
        mail_username: "noreplypqs@gmail.com",
        mail_password: "pruebadeemail"
        emailing_module: Mypass.Mailer,
  """

  @doc """
  Sends a welcome mail to the user.

  Subject and body can be configured in :phoenix_token_auth, :welcome_email_subject and :welcome_email_body.
  Both config fields have to be functions returning binaries. welcome_email_subject receives the user and
  welcome_email_body the user and confirmation token.
  """
  def send_welcome_email(user, confirmation_token, conn \\ nil) do
    from = Application.get_env(:phoenix_token_auth, :email_sender)
    subject = email_mod.welcome_subject(user, conn)
    body = email_mod.welcome_body(user, confirmation_token, conn)

    {:ok, _} = send_mail(from, user.email, subject, body) 

    Logger.info "Sent welcome email to #{user.email}"
  end

  @doc """
  Sends an email with instructions on how to reset the password to the user.

  Subject and body can be configured in :phoenix_token_auth, :password_reset_email_subject and :password_reset_email_body.
  Both config fields have to be functions returning binaries. password_reset_email_subject receives the user and
  password_reset_email_body the user and reset token.
  """
  def send_password_reset_email(user, reset_token, conn \\ nil) do
    subject = email_mod.password_reset_subject(user, conn)
    body = email_mod.password_reset_body(user, reset_token, conn)
    from = Application.get_env(:phoenix_token_auth, :email_sender)

    {:ok, _} = send_mail(from, user.email, subject, body) 

    Logger.info "Sent password_reset email to #{user.email}"
  end

  @doc """
  Sends an email with instructions on how to confirm a new email address to the user.

  Subject and body can be configured in :phoenix_token_auth, :new_email_address_email_subject and :new_email_address_email_body.
  Both config fields have to be functions returning binaries. new_email_address_email_subject receives the user and
  new_email_address_email_body the user and confirmation token.
  """
  def send_new_email_address_email(user, confirmation_token, conn \\ nil) do
    subject = email_mod.new_email_address_subject(user, conn)
    body = email_mod.new_email_address_body(user, confirmation_token, conn)
    from = Application.get_env(:phoenix_token_auth, :email_sender)

    {:ok, _} = send_mail(from, user.email, subject, body) 

    Logger.info "Sent new email address email to #{user.unconfirmed_email}"
  end

  defp email_mod do
    Application.get_env(:phoenix_token_auth, :emailing_module)
  end


  defp send_mail(from, to, subject, body) do
    :gen_smtp_client.send({to_string(from), [to_string(to)], 'Subject: ' ++  String.to_char_list(subject) ++ '\r\nFrom: MyPass.info \r\nTo: \r\n\r\n.' ++ String.to_char_list(body)}, [{:relay, Application.get_env(:phoenix_token_auth, :mail_relay)}, {:username, Application.get_env(:phoenix_token_auth, :mail_username)}, {:password, Application.get_env(:phoenix_token_auth, :mail_password)}, {:tls, Application.get_env(:phoenix_token_auth, :tls, :always)}, {:port, Application.get_env(:phoenix_token_auth, :port, 587)}])
  end

end
