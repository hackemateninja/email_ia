# EmailIa

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Set up environment variables (see Environment Variables section below)
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Environment Variables

This application requires the following environment variables to be set:

```bash
# Google OAuth Configuration
export GOOGLE_CLIENT_ID="your_google_client_id_here"
export GOOGLE_CLIENT_SECRET="your_google_client_secret_here"
export GOOGLE_REFRESH_TOKEN="your_google_refresh_token_here"
```

You can set these in your shell or create a `.env` file and source it before running the application.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
