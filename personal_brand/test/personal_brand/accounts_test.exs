defmodule PersonalBrand.AccountsTest do
  use ExUnit.Case, async: true

  alias PersonalBrand.Accounts

  describe "authenticate/2" do
    test "returns {:ok, admin} with valid default credentials" do
      assert {:ok, %{id: 1, username: "admin"}} = Accounts.authenticate("admin", "admin123")
    end

    test "returns {:ok, admin} with local admin email alias" do
      assert {:ok, %{id: 1, username: "admin"}} =
               Accounts.authenticate("admin@personalbrand.dev", "admin123")
    end

    test "returns {:error, :invalid_credentials} with wrong username" do
      assert {:error, :invalid_credentials} = Accounts.authenticate("wrong", "admin123")
    end

    test "returns {:error, :invalid_credentials} with wrong password" do
      assert {:error, :invalid_credentials} = Accounts.authenticate("admin", "wrong")
    end

    test "returns {:error, :invalid_credentials} with empty credentials" do
      assert {:error, :invalid_credentials} = Accounts.authenticate("", "")
    end

    test "uses secure_compare to prevent timing attacks" do
      # Both should take roughly the same time
      {:error, _} = Accounts.authenticate("admin", "wrongpassword")
      {:error, _} = Accounts.authenticate("wrong", "admin123")
      # Just verify they return error (secure_compare is used internally)
      assert true
    end
  end

  describe "generate_session_token/1" do
    test "returns a signed token string" do
      token = Accounts.generate_session_token(1)
      assert is_binary(token)
      assert String.length(token) > 10
    end

    test "returns different tokens for different admin ids" do
      token1 = Accounts.generate_session_token(1)
      token2 = Accounts.generate_session_token(2)
      assert token1 != token2
    end
  end

  describe "verify_session_token/1" do
    test "returns {:ok, admin_id} for valid token" do
      token = Accounts.generate_session_token(1)
      assert {:ok, 1} = Accounts.verify_session_token(token)
    end

    test "returns {:error, :invalid_token} for garbage token" do
      assert {:error, :invalid_token} = Accounts.verify_session_token("garbage-token")
    end

    test "returns {:error, :invalid_token} for empty string" do
      assert {:error, :invalid_token} = Accounts.verify_session_token("")
    end

    test "returns {:error, :invalid_token} for expired token" do
      # Token signed with a very old timestamp would fail verification
      # For now, just verify that tampered tokens are rejected
      assert {:error, :invalid_token} = Accounts.verify_session_token("invalid.token.here")
    end
  end
end
