defmodule EmailIa.DemosTest do
  use EmailIa.DataCase

  alias EmailIa.Demos

  describe "demos" do
    alias EmailIa.Demos.Demo

    import EmailIa.DemosFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_demos/0 returns all demos" do
      demo = demo_fixture()
      assert Demos.list_demos() == [demo]
    end

    test "get_demo!/1 returns the demo with given id" do
      demo = demo_fixture()
      assert Demos.get_demo!(demo.id) == demo
    end

    test "create_demo/1 with valid data creates a demo" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Demo{} = demo} = Demos.create_demo(valid_attrs)
      assert demo.name == "some name"
      assert demo.description == "some description"
    end

    test "create_demo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Demos.create_demo(@invalid_attrs)
    end

    test "update_demo/2 with valid data updates the demo" do
      demo = demo_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Demo{} = demo} = Demos.update_demo(demo, update_attrs)
      assert demo.name == "some updated name"
      assert demo.description == "some updated description"
    end

    test "update_demo/2 with invalid data returns error changeset" do
      demo = demo_fixture()
      assert {:error, %Ecto.Changeset{}} = Demos.update_demo(demo, @invalid_attrs)
      assert demo == Demos.get_demo!(demo.id)
    end

    test "delete_demo/1 deletes the demo" do
      demo = demo_fixture()
      assert {:ok, %Demo{}} = Demos.delete_demo(demo)
      assert_raise Ecto.NoResultsError, fn -> Demos.get_demo!(demo.id) end
    end

    test "change_demo/1 returns a demo changeset" do
      demo = demo_fixture()
      assert %Ecto.Changeset{} = Demos.change_demo(demo)
    end
  end
end
