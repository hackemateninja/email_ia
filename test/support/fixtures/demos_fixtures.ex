defmodule EmailIa.DemosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmailIa.Demos` context.
  """

  @doc """
  Generate a demo.
  """
  def demo_fixture(attrs \\ %{}) do
    {:ok, demo} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> EmailIa.Demos.create_demo()

    demo
  end
end
