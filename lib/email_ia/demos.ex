defmodule EmailIa.Demos do
  @moduledoc """
  The Demos context.
  """

  import Ecto.Query, warn: false
  alias EmailIa.Repo

  alias EmailIa.Demos.Demo

  @doc """
  Returns the list of demos.

  ## Examples

      iex> list_demos()
      [%Demo{}, ...]

  """
  def list_demos do
    Repo.all(Demo)
  end

  @doc """
  Gets a single demo.

  Raises `Ecto.NoResultsError` if the Demo does not exist.

  ## Examples

      iex> get_demo!(123)
      %Demo{}

      iex> get_demo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_demo!(id), do: Repo.get!(Demo, id)

  @doc """
  Creates a demo.

  ## Examples

      iex> create_demo(%{field: value})
      {:ok, %Demo{}}

      iex> create_demo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_demo(attrs \\ %{}) do
    %Demo{}
    |> Demo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a demo.

  ## Examples

      iex> update_demo(demo, %{field: new_value})
      {:ok, %Demo{}}

      iex> update_demo(demo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_demo(%Demo{} = demo, attrs) do
    demo
    |> Demo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a demo.

  ## Examples

      iex> delete_demo(demo)
      {:ok, %Demo{}}

      iex> delete_demo(demo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_demo(%Demo{} = demo) do
    Repo.delete(demo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking demo changes.

  ## Examples

      iex> change_demo(demo)
      %Ecto.Changeset{data: %Demo{}}

  """
  def change_demo(%Demo{} = demo, attrs \\ %{}) do
    Demo.changeset(demo, attrs)
  end
end
