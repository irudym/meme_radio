defmodule MemeRadio.Repo do
  use Ecto.Repo,
    otp_app: :meme_radio,
    adapter: Ecto.Adapters.Postgres
end
