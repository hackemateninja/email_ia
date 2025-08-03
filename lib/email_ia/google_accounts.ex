defmodule EmailIa.GoogleAccounts do
  @moduledoc """
  The GoogleAccounts context.
  """

  import Ecto.Query, warn: false
  alias EmailIa.Repo

  alias EmailIa.GoogleAccounts.GoogleAccount

  @doc """
  Returns the list of google_acounts.

  ## Examples

      iex> list_google_acounts()
      [%GoogleAccount{}, ...]

  """
  def list_google_acounts do
    Repo.all(GoogleAccount)
  end

  @doc """
  Gets a single google_account.

  Raises `Ecto.NoResultsError` if the Google account does not exist.

  ## Examples

      iex> get_google_account!(123)
      %GoogleAccount{}

      iex> get_google_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_google_account!(id), do: Repo.get!(GoogleAccount, id)

  @doc """
  Creates a google_account.

  ## Examples

      iex> create_google_account(%{field: value})
      {:ok, %GoogleAccount{}}

      iex> create_google_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_google_account(attrs \\ %{}) do
    %GoogleAccount{}
    |> GoogleAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a google_account.

  ## Examples

      iex> update_google_account(google_account, %{field: new_value})
      {:ok, %GoogleAccount{}}

      iex> update_google_account(google_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_google_account(%GoogleAccount{} = google_account, attrs) do
    google_account
    |> GoogleAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a google_account.

  ## Examples

      iex> delete_google_account(google_account)
      {:ok, %GoogleAccount{}}

      iex> delete_google_account(google_account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_google_account(%GoogleAccount{} = google_account) do
    Repo.delete(google_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking google_account changes.

  ## Examples

      iex> change_google_account(google_account)
      %Ecto.Changeset{data: %GoogleAccount{}}

  """
  def change_google_account(%GoogleAccount{} = google_account, attrs \\ %{}) do
    GoogleAccount.changeset(google_account, attrs)
  end
end
