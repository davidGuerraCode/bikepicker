defmodule MotorcycleAdvisor.AccountsTest do
  use MotorcycleAdvisor.DataCase, async: true

  alias MotorcycleAdvisor.Accounts

  @valid_attrs %{"email" => "rider@example.com", "password" => "supersecret123"}

  describe "register_user/1" do
    test "inserts with valid attrs and hashes the password" do
      assert {:ok, user} = Accounts.register_user(@valid_attrs)
      assert user.email == "rider@example.com"
      assert user.hashed_password != "supersecret123"
    end

    test "downcases email" do
      attrs = Map.put(@valid_attrs, "email", "Rider@Example.com")
      assert {:ok, user} = Accounts.register_user(attrs)
      assert user.email == "rider@example.com"
    end

    test "rejects duplicate email" do
      assert {:ok, _user} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "rejects short password" do
      attrs = Map.put(@valid_attrs, "password", "short")
      assert {:error, changeset} = Accounts.register_user(attrs)
      assert errors_on(changeset).password
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "returns the user with correct credentials" do
      {:ok, user} = Accounts.register_user(@valid_attrs)

      assert %{id: id} =
               Accounts.get_user_by_email_and_password("rider@example.com", "supersecret123")

      assert id == user.id
    end

    test "returns nil with wrong password" do
      {:ok, _user} = Accounts.register_user(@valid_attrs)
      assert Accounts.get_user_by_email_and_password("rider@example.com", "wrongpassword") == nil
    end

    test "returns nil when email doesn't exist" do
      assert Accounts.get_user_by_email_and_password("nobody@example.com", "whatever123") == nil
    end
  end

  describe "api tokens" do
    test "create_api_token/1 then get_user_by_api_token/1 round-trips" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      token = Accounts.create_api_token(user)

      assert %{id: id} = Accounts.get_user_by_api_token(token)
      assert id == user.id
    end

    test "get_user_by_api_token/1 returns nil for a bogus token" do
      assert Accounts.get_user_by_api_token("not-a-real-token") == nil
    end

    test "delete_api_token/1 invalidates the token" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      token = Accounts.create_api_token(user)

      Accounts.delete_api_token(token)

      assert Accounts.get_user_by_api_token(token) == nil
    end
  end
end
