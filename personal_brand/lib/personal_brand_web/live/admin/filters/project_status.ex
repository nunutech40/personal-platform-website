defmodule PersonalBrandWeb.Admin.Filters.ProjectStatus do
  @moduledoc """
  Backpex select filter for project publication status.
  """

  use Backpex.Filters.Select

  alias PersonalBrand.Content.Project

  @impl Backpex.Filter
  def label, do: "Status"

  @impl Backpex.Filters.Select
  def prompt, do: "All statuses"

  @impl Backpex.Filters.Select
  def options(_assigns), do: Enum.map(Project.statuses(), &{Project.label_for(&1), &1})
end
