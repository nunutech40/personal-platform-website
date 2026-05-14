defmodule PersonalBrand.Content.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(draft published archived)
  @project_types ~w(professional_work client_work open_source personal_project architecture_demo internal_tool case_study)
  @platforms ~w(ios android flutter macos web backend cross_platform)
  @disciplines ~w(mobile_developer flutter_developer ios_developer swift kotlin flutter android_developer backend_developer frontend_developer fullstack_developer ai_automation cli_tooling)
  @case_study_visibilities ~w(public limited private_summary)
  @labels %{
    "ios" => "iOS",
    "macos" => "macOS",
    "cross_platform" => "Cross-platform",
    "mobile_developer" => "Mobile Developer",
    "flutter_developer" => "Flutter Developer",
    "ios_developer" => "iOS Developer",
    "swift" => "Swift",
    "kotlin" => "Kotlin",
    "flutter" => "Flutter",
    "android_developer" => "Android Developer",
    "backend_developer" => "Backend Developer",
    "frontend_developer" => "Frontend Developer",
    "fullstack_developer" => "Full-Stack Developer",
    "ai_automation" => "AI Automation",
    "cli_tooling" => "CLI & Tooling",
    "professional_work" => "Professional Work",
    "client_work" => "Client Work",
    "open_source" => "Open Source",
    "personal_project" => "Personal Project",
    "architecture_demo" => "Architecture Demo",
    "internal_tool" => "Internal Tool",
    "case_study" => "Case Study",
    "private_summary" => "Private Summary"
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :title, :string
    field :slug, :string
    field :summary, :string
    field :description, :string
    field :problem, :string
    field :solution, :string
    field :result, {:array, :string}, default: []
    field :role, :string
    field :tech_stack, {:array, :string}, default: []
    field :year, :string
    field :status, :string, default: "draft"
    field :featured, :boolean, default: false
    field :best_three, :boolean, default: false
    field :demo_url, :string
    field :demo_video_url, :string
    field :github_url, :string
    belongs_to :cover_image, PersonalBrand.Content.Media
    belongs_to :certificate_media, PersonalBrand.Content.Media
    field :project_type, :string
    field :company, :string
    field :client, :string
    field :platforms, {:array, :string}, default: []
    field :disciplines, {:array, :string}, default: []
    field :ownership, :string
    field :team_size, :string
    field :duration, :string
    field :impact_summary, :string
    field :technical_highlights, {:array, :string}, default: []
    field :architecture_notes, :string
    field :tradeoffs, :string
    field :metrics, {:array, :string}, default: []
    field :app_store_url, :string
    field :case_study_visibility, :string, default: "public"
    field :sort_order, :integer, default: 0
    field :sort_date, :date

    many_to_many :tags, PersonalBrand.Content.Tag,
      join_through: "project_tags",
      on_replace: :delete

    timestamps()
  end

  def statuses, do: @statuses
  def project_types, do: @project_types
  def platforms, do: @platforms
  def disciplines, do: @disciplines
  def case_study_visibilities, do: @case_study_visibilities

  def label_for(value) when is_binary(value) do
    Map.get(@labels, value, humanize_value(value))
  end

  def label_for(value), do: value

  def slugify(value) when is_binary(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  def slugify(_value), do: ""

  defp humanize_value(value) do
    value
    |> String.replace("_", " ")
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  def changeset(project, attrs) do
    attrs = normalize_list_textareas(attrs)
    attrs = put_generated_slug(attrs)

    project
    |> cast(attrs, [
      :title,
      :slug,
      :summary,
      :description,
      :problem,
      :solution,
      :result,
      :role,
      :tech_stack,
      :year,
      :status,
      :featured,
      :best_three,
      :demo_url,
      :demo_video_url,
      :github_url,
      :cover_image_id,
      :certificate_media_id,
      :project_type,
      :company,
      :client,
      :platforms,
      :disciplines,
      :ownership,
      :team_size,
      :duration,
      :impact_summary,
      :technical_highlights,
      :architecture_notes,
      :tradeoffs,
      :metrics,
      :app_store_url,
      :case_study_visibility,
      :sort_order,
      :sort_date
    ])
    |> validate_required([:title, :slug, :status, :year])
    |> validate_length(:title, min: 2, max: 200)
    |> validate_length(:slug, min: 2, max: 200)
    |> validate_length(:summary, max: 500)
    |> validate_length(:role, max: 100)
    |> validate_length(:ownership, max: 160)
    |> validate_length(:team_size, max: 80)
    |> validate_length(:duration, max: 80)
    |> validate_optional_inclusion(:status, @statuses)
    |> validate_optional_inclusion(:project_type, @project_types)
    |> validate_optional_inclusion(:case_study_visibility, @case_study_visibilities)
    |> validate_list_subset(:platforms, @platforms)
    |> validate_list_subset(:disciplines, @disciplines)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with hyphens only"
    )
    |> validate_format(:demo_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> validate_format(:demo_video_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> validate_format(:github_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> validate_format(:app_store_url, ~r/^https?:\/\//,
      message: "must start with http:// or https://"
    )
    |> unique_constraint(:slug)
  end

  def changeset(project, attrs, _metadata), do: changeset(project, attrs)

  defp normalize_list_textareas(attrs) when is_map(attrs) do
    attrs
    |> normalize_list_textarea(:result)
    |> normalize_list_textarea(:tech_stack)
    |> normalize_list_textarea(:platforms)
    |> normalize_list_textarea(:disciplines)
    |> normalize_list_textarea(:technical_highlights)
    |> normalize_list_textarea(:metrics)
    |> normalize_blank_value(:demo_url)
    |> normalize_blank_value(:demo_video_url)
    |> normalize_blank_value(:github_url)
    |> normalize_blank_value(:app_store_url)
  end

  defp normalize_list_textareas(attrs), do: attrs

  defp normalize_list_textarea(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      is_binary(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &split_textarea_value/1)

      is_binary(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &split_textarea_value/1)

      is_list(Map.get(attrs, field)) ->
        Map.update!(attrs, field, &normalize_list_value/1)

      is_list(Map.get(attrs, string_key)) ->
        Map.update!(attrs, string_key, &normalize_list_value/1)

      true ->
        attrs
    end
  end

  defp split_textarea_value(value) do
    value
    |> String.split(~r/\r?\n/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_blank_value(attrs, field) do
    string_key = Atom.to_string(field)

    cond do
      Map.get(attrs, field) == "" -> Map.put(attrs, field, nil)
      Map.get(attrs, string_key) == "" -> Map.put(attrs, string_key, nil)
      true -> attrs
    end
  end

  defp normalize_list_value(value) do
    value
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp put_generated_slug(attrs) when is_map(attrs) do
    slug = get_attr(attrs, :slug)
    title = get_attr(attrs, :title)

    if blank?(slug) and is_binary(title) do
      put_attr(attrs, :slug, slugify(title))
    else
      attrs
    end
  end

  defp put_generated_slug(attrs), do: attrs

  defp validate_optional_inclusion(changeset, field, values) do
    value = get_field(changeset, field)

    if blank?(value) do
      changeset
    else
      validate_inclusion(changeset, field, values)
    end
  end

  defp validate_list_subset(changeset, field, values) do
    field_values = get_field(changeset, field) || []
    invalid_values = Enum.reject(field_values, &(&1 in values))

    if invalid_values == [] do
      changeset
    else
      add_error(changeset, field, "contains invalid values: #{Enum.join(invalid_values, ", ")}")
    end
  end

  defp get_attr(attrs, field) do
    Map.get(attrs, field) || Map.get(attrs, Atom.to_string(field))
  end

  defp put_attr(attrs, field, value) do
    cond do
      Map.has_key?(attrs, field) -> Map.put(attrs, field, value)
      Map.has_key?(attrs, Atom.to_string(field)) -> Map.put(attrs, Atom.to_string(field), value)
      true -> Map.put(attrs, field, value)
    end
  end

  defp blank?(value), do: is_nil(value) or value == ""
end
