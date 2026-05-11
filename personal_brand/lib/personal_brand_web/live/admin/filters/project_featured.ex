defmodule PersonalBrandWeb.Admin.Filters.ProjectFeatured do
  @moduledoc """
  Backpex boolean filter for featured projects.
  """

  use Backpex.Filters.Boolean

  import Ecto.Query

  @impl Backpex.Filter
  def label, do: "Featured"

  @impl Backpex.Filters.Boolean
  def options(_assigns) do
    [
      %{
        label: "Featured only",
        key: "featured",
        predicate: dynamic([project], project.featured == true)
      }
    ]
  end
end
