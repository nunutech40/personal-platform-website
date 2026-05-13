defmodule PersonalBrandWeb.Admin.Fields.MarkdownEditor do
  @config_schema [
    placeholder: [
      doc: "Placeholder value or function that receives the assigns.",
      type: {:or, [:string, {:fun, 1}]}
    ],
    debounce: [
      doc: "Timeout value (in milliseconds), \"blur\" or function that receives the assigns.",
      type: {:or, [:pos_integer, :string, {:fun, 1}]}
    ],
    throttle: [
      doc: "Timeout value (in milliseconds) or function that receives the assigns.",
      type: {:or, [:pos_integer, {:fun, 1}]}
    ],
    rows: [
      doc: "Number of visible text lines for the editor.",
      type: :non_neg_integer,
      default: 16
    ],
    readonly: [
      doc: "Sets the field to readonly. Also see the Backpex readonly panels guide.",
      type: {:or, [:boolean, {:fun, 1}]}
    ]
  ]

  @moduledoc """
  Markdown editor field for admin post content.

  It keeps the same Backpex field contract as `Backpex.Fields.Textarea`, then adds
  an EasyMDE-powered admin editor via the `AdminMarkdownEditor` hook.
  """
  use Backpex.Field, config_schema: @config_schema

  @impl Backpex.Field
  def render_value(assigns) do
    ~H"""
    <p
      class={[
        @live_action in [:index, :resource_action] && "truncate",
        @live_action == :show && "overflow-x-auto whitespace-pre-wrap"
      ]}
      phx-no-format
    ><%= HTML.pretty_value(@value) %></p>
    """
  end

  @impl Backpex.Field
  def render_form(assigns) do
    ~H"""
    <div>
      <Layout.field_container>
        <:label :if={not @hide_label} align={Backpex.Field.align_label(@field_options, assigns, :top)}>
          <Layout.input_label for={@form[@name]} text={@field_options[:label]} />
        </:label>
        <div
          id={"markdown-editor-#{@form[@name].id}"}
          class="admin-markdown-editor"
          phx-hook="AdminMarkdownEditor"
        >
          <BackpexForm.input
            type="textarea"
            field={@form[@name]}
            placeholder={@field_options[:placeholder]}
            rows={@field_options[:rows]}
            input_class="textarea w-full admin-markdown-textarea"
            translate_error_fun={Backpex.Field.translate_error_fun(@field_options, assigns)}
            help_text={Backpex.Field.help_text(@field_options, assigns)}
            phx-debounce={Backpex.Field.debounce(@field_options, assigns)}
            phx-throttle={Backpex.Field.throttle(@field_options, assigns)}
            readonly={@readonly}
            disabled={@readonly}
            aria-labelledby={Map.get(assigns, :aria_labelledby)}
          />
        </div>
      </Layout.field_container>
    </div>
    """
  end
end
