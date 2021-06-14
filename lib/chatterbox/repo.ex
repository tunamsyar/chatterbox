defmodule Chatterbox.Repo do
  use Ecto.Repo,
    otp_app: :chatterbox,
    adapter: Ecto.Adapters.Postgres
end
