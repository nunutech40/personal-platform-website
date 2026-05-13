defmodule PersonalBrand.Content.Markdown do
  @moduledoc """
  Markdown rendering for writing content.

  Admin posts keep Markdown as the editable source. Public pages render the
  generated, sanitized HTML from here instead of trusting raw editor output.
  """

  @options [
    extension: [
      autolink: true,
      strikethrough: true,
      table: true,
      tasklist: true
    ],
    sanitize: MDEx.Document.default_sanitize_options()
  ]

  def to_html(nil), do: nil
  def to_html(""), do: nil

  def to_html(markdown) when is_binary(markdown) do
    markdown
    |> String.trim()
    |> case do
      "" -> nil
      value -> MDEx.to_html!(value, @options)
    end
  end

  def to_html(_markdown), do: nil
end
