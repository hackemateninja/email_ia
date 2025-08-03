defmodule EmailIa.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmailIa.Categories` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> EmailIa.Categories.create_category()

    category
  end
end
