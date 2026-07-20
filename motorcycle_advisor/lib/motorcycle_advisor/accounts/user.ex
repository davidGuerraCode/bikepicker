defmodule MotorcycleAdvisor.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias MotorcycleAdvisor.Repo

  @derive {Jason.Encoder, only: [:id, :email, :inserted_at]}

  schema "users" do
    field :email, :string
    field :hashed_password, :string, redact: true
    field :password, :string, virtual: true, redact: true

    timestamps()
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> update_change(:email, &String.downcase/1)
    |> unsafe_validate_unique(:email, Repo)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8, max: 72)
    |> put_hashed_password()
  end

  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
