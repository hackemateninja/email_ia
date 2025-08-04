defmodule EmailIaWeb.DemoLiveTest do
  use EmailIaWeb.ConnCase

  import Phoenix.LiveViewTest
  import EmailIa.DemosFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  defp create_demo(_) do
    demo = demo_fixture()
    %{demo: demo}
  end

  describe "Index" do
    setup [:create_demo]

    test "lists all demos", %{conn: conn, demo: demo} do
      {:ok, _index_live, html} = live(conn, ~p"/demos")

      assert html =~ "Listing Demos"
      assert html =~ demo.name
    end

    test "saves new demo", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/demos")

      assert index_live |> element("a", "New Demo") |> render_click() =~
               "New Demo"

      assert_patch(index_live, ~p"/demos/new")

      assert index_live
             |> form("#demo-form", demo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#demo-form", demo: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/demos")

      html = render(index_live)
      assert html =~ "Demo created successfully"
      assert html =~ "some name"
    end

    test "updates demo in listing", %{conn: conn, demo: demo} do
      {:ok, index_live, _html} = live(conn, ~p"/demos")

      assert index_live |> element("#demos-#{demo.id} a", "Edit") |> render_click() =~
               "Edit Demo"

      assert_patch(index_live, ~p"/demos/#{demo}/edit")

      assert index_live
             |> form("#demo-form", demo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#demo-form", demo: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/demos")

      html = render(index_live)
      assert html =~ "Demo updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes demo in listing", %{conn: conn, demo: demo} do
      {:ok, index_live, _html} = live(conn, ~p"/demos")

      assert index_live |> element("#demos-#{demo.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#demos-#{demo.id}")
    end
  end

  describe "Show" do
    setup [:create_demo]

    test "displays demo", %{conn: conn, demo: demo} do
      {:ok, _show_live, html} = live(conn, ~p"/demos/#{demo}")

      assert html =~ "Show Demo"
      assert html =~ demo.name
    end

    test "updates demo within modal", %{conn: conn, demo: demo} do
      {:ok, show_live, _html} = live(conn, ~p"/demos/#{demo}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Demo"

      assert_patch(show_live, ~p"/demos/#{demo}/show/edit")

      assert show_live
             |> form("#demo-form", demo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#demo-form", demo: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/demos/#{demo}")

      html = render(show_live)
      assert html =~ "Demo updated successfully"
      assert html =~ "some updated name"
    end
  end
end
