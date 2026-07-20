defmodule MotorcycleAdvisor.Accounts do
  alias MotorcycleAdvisor.Repo
  alias MotorcycleAdvisor.Accounts.{User, UserToken}

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) ->
        user

      user ->
        nil

      true ->
        Bcrypt.no_user_verify()
        nil
    end
  end

  def create_api_token(user) do
    {encoded_token, user_token} = UserToken.build_api_token(user)
    Repo.insert!(user_token)
    encoded_token
  end

  def get_user_by_api_token(encoded_token) do
    with {:ok, query} <- UserToken.verify_api_token_query(encoded_token),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  def delete_api_token(encoded_token) do
    with {:ok, decoded_token} <- Base.url_decode64(encoded_token, padding: false) do
      hashed_token = :crypto.hash(:sha256, decoded_token)

      hashed_token
      |> UserToken.token_and_context_query("api-auth")
      |> Repo.delete_all()
    end

    :ok
  end
end
