defmodule Readout.Curation.Digest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "digests" do
    field :date, :date

    belongs_to :user, Readout.Accounts.User
    has_many :items, Readout.Curation.DigestItem

    timestamps(type: :utc_datetime)
  end

  def changeset(digest, attrs) do
    digest
    |> cast(attrs, [:user_id, :date])
    |> validate_required([:user_id, :date])
    |> unique_constraint([:user_id, :date])
  end
end
