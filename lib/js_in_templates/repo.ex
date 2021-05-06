defmodule JsInTemplates.Repo do
  use Ecto.Repo,
    otp_app: :js_in_templates,
    adapter: Ecto.Adapters.Postgres
end
