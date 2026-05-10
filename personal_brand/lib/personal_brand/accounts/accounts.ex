defmodule PersonalBrand.Accounts do
  @moduledoc """
  The Accounts context manages admin authentication.
  For MVP, uses a simple single-admin approach with
  credential check against environment variables.
  """

  import Plug.Crypto, only: [secure_compare: 2]

  @doc """
  Authenticate admin by username and password.
  Returns {:ok, admin_id} or {:error, :invalid_credentials}.
  """
  def authenticate(username, password) do
    admin_username = Application.get_env(:personal_brand, :admin_username) || "admin"
    admin_password = Application.get_env(:personal_brand, :admin_password) || "admin123"

    if secure_compare(username, admin_username) and secure_compare(password, admin_password) do
      {:ok, %{id: 1, username: admin_username}}
    else
      {:error, :invalid_credentials}
    end
  end

  @doc """
  Generate a signed admin session token.
  """
  def generate_session_token(admin_id) do
    Phoenix.Token.sign(PersonalBrandWeb.Endpoint, "admin_session", admin_id)
  end

  @doc """
  Verify an admin session token.
  Returns {:ok, admin_id} or {:error, :invalid_token}.
  """
  def verify_session_token(token) do
    case Phoenix.Token.verify(PersonalBrandWeb.Endpoint, "admin_session", token,
           max_age: 86400 * 7
         ) do
      {:ok, admin_id} -> {:ok, admin_id}
      {:error, _reason} -> {:error, :invalid_token}
    end
  end
end
