# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :js_in_templates,
  ecto_repos: [JsInTemplates.Repo]

# Configures the endpoint
config :js_in_templates, JsInTemplatesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9dbF8xbFhD/91PlDTZ2x/mzBj2eeWzXM6G5m1dw4MGPpaGBEEhTb8i0hSKn6zmj6",
  render_errors: [view: JsInTemplatesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: JsInTemplates.PubSub,
  live_view: [signing_salt: "kj4q3OnX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Templates
config :phoenix, :template_engines, eex: JsInTemplatesWeb.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
