defmodule MotorcycleAdvisor.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query

  alias MotorcycleAdvisor.Accounts.UserToken

  @api_token_context "api-auth"
  @api_token_validity_days 60
  @rand_size 32

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    belongs_to :user, MotorcycleAdvisor.Accounts.User

    timestamps(updated_at: false)
  end

  def build_api_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(:sha256, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{token: hashed_token, context: @api_token_context, user_id: user.id}}
  end

  def verify_api_token_query(encoded_token) do
    case Base.url_decode64(encoded_token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(:sha256, decoded_token)
        days_ago = DateTime.utc_now() |> DateTime.add(-@api_token_validity_days, :day)

        query =
          from token in token_and_context_query(hashed_token, @api_token_context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ^days_ago,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  def token_and_context_query(token, context) do
    from t in UserToken, where: t.token == ^token and t.context == ^context
  end
end
