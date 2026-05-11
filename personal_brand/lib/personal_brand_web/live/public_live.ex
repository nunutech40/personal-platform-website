defmodule PersonalBrandWeb.PublicLive do
  use PersonalBrandWeb, :live_view

  alias PersonalBrand.Content
  alias PersonalBrand.Content.Project

  # ── Mount ────────────────────────────────────────────────

  def mount(_params, _session, socket) do
    settings = Content.get_site_settings!()
    theme_class = theme_class_name(settings.active_theme)

    socket =
      assign(socket,
        site_name: settings.site_name,
        profile_name: settings.profile_name,
        profile_title: settings.profile_title,
        profile_bio: settings.profile_bio,
        profile_email: settings.profile_email,
        profile_location: settings.profile_location,
        social_links: settings.social_links || %{},
        ordered_social_links:
          ordered_social_links(settings.social_links || %{}, settings.profile_email),
        active_theme: settings.active_theme,
        theme_class: theme_class,
        page_title: settings.site_name,
        settings: settings,
        page: :home
      )

    {:ok, socket, layout: {PersonalBrandWeb.Layouts, :public}}
  end

  # ── Route Handling ───────────────────────────────────────

  def handle_params(%{"slug" => slug}, _uri, socket) do
    path = socket.assigns.live_action

    case path do
      :work_detail ->
        case Content.get_published_project_by_slug(slug) do
          nil ->
            {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}

          project ->
            {:noreply,
             assign(socket,
               page: :work_detail,
               project: project,
               cover_media: Content.get_media(project.cover_image_id),
               page_title: project.title
             )}
        end

      :writing_detail ->
        case Content.get_post_by_slug(slug) do
          nil ->
            {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}

          post ->
            {:noreply, assign(socket, page: :writing_detail, post: post, page_title: post.title)}
        end

      :product_detail ->
        case Content.get_product_by_slug(slug) do
          nil ->
            {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}

          product ->
            {:noreply,
             assign(socket, page: :product_detail, product: product, page_title: product.title)}
        end

      _ ->
        {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}
    end
  end

  def handle_params(params, _uri, socket) do
    path = socket.assigns.live_action

    socket =
      case path do
        :index ->
          settings = socket.assigns.settings
          projects = Content.list_featured_projects()
          posts = Content.list_featured_posts()
          products = Content.list_featured_products()
          project_media = media_by_id(projects)

          assign(socket,
            page: :home,
            page_title: "Home",
            projects: projects,
            project_media: project_media,
            posts: posts,
            products: products,
            settings: settings
          )

        :work_index ->
          active_filter = work_filter_from_params(params)
          projects = Content.list_published_projects(active_filter_query(active_filter))

          assign(socket,
            page: :work_index,
            page_title: "Work",
            projects: projects,
            work_filters: work_filters(),
            active_filter: active_filter,
            project_media: media_by_id(projects)
          )

        :writing_index ->
          posts = Content.list_posts()
          assign(socket, page: :writing_index, page_title: "Writing", posts: posts)

        :products_index ->
          products = Content.list_products()
          assign(socket, page: :products_index, page_title: "Products", products: products)

        :about_page ->
          assign(socket, page: :about_page, page_title: "About")

        :now_page ->
          assign(socket, page: :now_page, page_title: "Now")

        :contact_page ->
          assign(socket, page: :contact_page, page_title: "Contact")

        _ ->
          assign(socket, page: :not_found, page_title: "Not Found")
      end

    {:noreply, socket}
  end

  # ── Render ───────────────────────────────────────────────

  def render(assigns) do
    ~H"""
    <%= case @page do %>
      <% :home -> %>
        <.homepage
          settings={@settings}
          projects={@projects}
          project_media={@project_media}
          posts={@posts}
          products={@products}
        />
      <% :work_index -> %>
        <.work_index
          projects={@projects}
          project_media={@project_media}
          filters={@work_filters}
          active_filter={@active_filter}
        />
      <% :work_detail -> %>
        <.work_detail project={@project} cover_media={@cover_media} />
      <% :writing_index -> %>
        <.writing_index posts={@posts} />
      <% :writing_detail -> %>
        <.writing_detail post={@post} />
      <% :products_index -> %>
        <.products_index products={@products} />
      <% :product_detail -> %>
        <.product_detail product={@product} />
      <% :about_page -> %>
        <.about_page profile_bio={@profile_bio} />
      <% :now_page -> %>
        <.now_page />
      <% :contact_page -> %>
        <.contact_page profile_email={@profile_email} social_links={@ordered_social_links} />
      <% _ -> %>
        <.not_found />
    <% end %>
    """
  end

  # ── Homepage ─────────────────────────────────────────────

  def homepage(assigns) do
    ~H"""
    <section>
      <p class="lead">{@settings.headline}</p>
      <p>{@settings.subheadline}</p>
      <p class="cta-row">
        <a href={@settings.primary_cta_url}>{@settings.primary_cta_text}</a>
        <a href={@settings.secondary_cta_url}>{@settings.secondary_cta_text}</a>
      </p>
    </section>
    <hr />
    <div class="home-grid">
      <div class="home-lists">
        <.featured_work projects={@projects} />
        <.recent_writing posts={@posts} />
        <.featured_products products={@products} />
        <.now_block />
      </div>
      <.visual_frame
        text="Ship small. Learn fast."
        media={first_project_media(@projects, @project_media)}
      />
    </div>
    """
  end

  # ── Work Index ───────────────────────────────────────────

  def work_index(assigns) do
    ~H"""
    <h1>Work</h1>
    <p>Project portfolio untuk menunjukkan ownership, technical depth, dan impact.</p>
    <nav class="tag-list" aria-label="Work filters">
      <a
        :for={filter <- @filters}
        href={filter.href}
        class={if filter.key == @active_filter.key, do: "tag active", else: "tag"}
      >
        {filter.label}
      </a>
    </nav>
    <hr />
    <div class="detail-grid">
      <section>
        <%= if @projects == [] do %>
          <.empty_state text="No published projects yet." />
        <% end %>
        <%= for project <- @projects do %>
          <article class="item">
            <div class="item-title">
              <a href={"/work/#{project.slug}"}>{project.title}</a>
            </div>
            <p>{project.summary}</p>
            <p :if={project.impact_summary} class="lead">{project.impact_summary}</p>
            <p class="meta">
              {project.role}
              <%= if project.duration || project.year do %>
                · {project.duration || project.year}
              <% end %>
            </p>
            <div class="tag-list">
              <span :for={badge <- project_badges(project)} class="tag">{badge}</span>
            </div>
            <p class="meta">{Enum.join(project.tech_stack || [], ", ")}</p>
          </article>
        <% end %>
      </section>
      <.visual_frame
        text="Project screenshots live here."
        media={first_project_media(@projects, @project_media)}
      />
    </div>
    """
  end

  # ── Work Detail ──────────────────────────────────────────

  def work_detail(assigns) do
    ~H"""
    <p class="breadcrumb"><a href="/work">Work</a> / {@project.title}</p>
    <div class="detail-grid">
      <article>
        <h1>{@project.title}</h1>
        <p class="tagline">{@project.summary}</p>
        <p>
          <strong>Role:</strong> {@project.role}<br />
          <strong>Ownership:</strong> {@project.ownership || "Case study contributor"}<br />
          <strong>Platform:</strong> {Enum.join(project_badges(@project), ", ")}<br />
          <strong>Stack:</strong> {Enum.join(@project.tech_stack || [], ", ")}<br />
          <strong>Period:</strong> {@project.duration || @project.year}
        </p>
        <p :if={@project.case_study_visibility in ["limited", "private_summary"]} class="notice">
          Some implementation details are summarized to respect proprietary project boundaries.
        </p>
        <.detail_section title="Overview" body={@project.description} />
        <.detail_section title="Problem" body={@project.problem} />
        <.detail_section title="My Role & Ownership" body={@project.ownership} />
        <.detail_section title="Technical Approach" body={@project.solution} />
        <.detail_section title="Architecture Notes" body={@project.architecture_notes} />
        <.detail_section title="Trade-offs" body={@project.tradeoffs} />
        <section :if={@project.technical_highlights != []} class="detail-section">
          <h2>Implementation Highlights</h2>
          <ul>
            <li :for={item <- @project.technical_highlights}>{item}</li>
          </ul>
        </section>
        <section class="detail-section">
          <h2>Results</h2>
          <ul>
            <li :if={@project.impact_summary}>{@project.impact_summary}</li>
            <li :for={item <- @project.result}>{item}</li>
            <li :for={item <- @project.metrics}>{item}</li>
          </ul>
        </section>
        <section class="detail-section">
          <h2>Links</h2>
          <ul>
            <li :if={@project.demo_url}><a href={@project.demo_url}>Live Demo</a></li>
            <li :if={@project.github_url}><a href={@project.github_url}>GitHub</a></li>
            <li :if={@project.app_store_url}><a href={@project.app_store_url}>App Store</a></li>
          </ul>
        </section>
      </article>
      <.visual_frame text={"#{@project.title} case study"} media={@cover_media} />
    </div>
    """
  end

  # ── Writing Index ────────────────────────────────────────

  def writing_index(assigns) do
    ~H"""
    <h1>Writing</h1>
    <p>Builder notes, Flutter lessons, product thinking, and short essays.</p>
    <hr />
    <%= if @posts == [] do %>
      <.empty_state text="No published writing yet." />
    <% end %>
    <%= for post <- @posts do %>
      <article class="item">
        <div class="item-title"><a href={"/writing/#{post.slug}"}>{post.title}</a></div>
        <p class="meta">{format_date(post.published_at)} · {post.reading_time} min read</p>
        <p>{post.excerpt}</p>
        <div class="tag-list">
          <span :for={tag <- post.tags} class="tag">{tag}</span>
        </div>
      </article>
    <% end %>
    """
  end

  # ── Writing Detail ───────────────────────────────────────

  def writing_detail(assigns) do
    ~H"""
    <p class="breadcrumb"><a href="/writing">Writing</a> / {@post.title}</p>
    <article>
      <h1>{@post.title}</h1>
      <p class="meta">{format_date(@post.published_at)} · {@post.reading_time} min read</p>
      <p class="lead">{@post.excerpt}</p>
      <hr />
      <div class="article-body">
        {Phoenix.HTML.raw(@post.content_html || @post.content_markdown || "")}
      </div>
      <hr />
      <p><a href="/writing">Back to writing</a> | <a href="/work">See related work</a></p>
    </article>
    """
  end

  # ── Products Index ───────────────────────────────────────

  def products_index(assigns) do
    ~H"""
    <h1>Products</h1>
    <p>Digital products and experiments. MVP checkout uses external payment links.</p>
    <div class="notice">
      Phase 1 commerce mode: product detail pages redirect to a manual Midtrans Payment Link through <code>checkout_url</code>.
    </div>
    <hr />
    <%= if @products == [] do %>
      <.empty_state text="No products are listed yet." />
    <% end %>
    <%= for product <- @products do %>
      <article class="item">
        <div class="item-title"><a href={"/products/#{product.slug}"}>{product.title}</a></div>
        <p>{product.summary}</p>
        <p class="meta">{product.product_type} · {format_money(product)} · {product.stock_status}</p>
      </article>
    <% end %>
    """
  end

  # ── Product Detail ───────────────────────────────────────

  def product_detail(assigns) do
    ~H"""
    <p class="breadcrumb"><a href="/products">Products</a> / {@product.title}</p>
    <div class="detail-grid">
      <article>
        <h1>{@product.title}</h1>
        <p class="lead">{@product.summary}</p>
        <p class="price">{format_money(@product)}</p>
        <p>
          <strong>Type:</strong> {@product.product_type}<br />
          <strong>Delivery:</strong> {@product.delivery_type}<br />
          <strong>Status:</strong> {@product.stock_status}
        </p>
        <p :if={@product.checkout_url}>
          <a href={@product.checkout_url} class="button-link">Buy Now</a>
        </p>
        <p :if={@product.status != "active"} class="notice">
          This product is currently marked as {@product.status}.
        </p>
        <.detail_section title="Why I Made This" body={@product.description} />
        <section class="detail-section">
          <h2>What Included</h2>
          <ul>
            <li :for={item <- @product.included}>{item}</li>
          </ul>
        </section>
        <section class="detail-section">
          <h2>FAQ</h2>
          <%= for {question, answer} <- @product.faq do %>
            <h3>{question}</h3>
            <p>{answer}</p>
          <% end %>
        </section>
      </article>
      <.visual_frame text={"#{@product.title} preview"} />
    </div>
    """
  end

  # ── About Page ───────────────────────────────────────────

  def about_page(assigns) do
    ~H"""
    <div class="detail-grid">
      <section>
        <h1>About</h1>
        <p>{@profile_bio}</p>
        <p>
          I like useful mobile apps, calm interfaces, readable code, and small products that solve real problems.
        </p>
      </section>
      <.visual_frame text="Handmade but useful." />
    </div>
    <hr />
    <div class="two-col">
      <section>
        <h2>What I Do</h2>
        <p>I build mobile apps with Flutter, from idea to release.</p>
        <p>I turn fuzzy product ideas into simple flows, prototypes, and shipped software.</p>
        <h2>Tools I Use</h2>
        <ul>
          <li><a href="https://flutter.dev">Flutter</a> for mobile apps</li>
          <li><a href="https://elixir-lang.org">Elixir</a> for scalable backend logic</li>
          <li><a href="https://www.postgresql.org">PostgreSQL</a> for relational data</li>
          <li><a href="https://figma.com">Figma</a> for product design</li>
        </ul>
      </section>
      <section>
        <h2>What I Care About</h2>
        <ul>
          <li>Building useful things that solve real problems</li>
          <li>Clean code, simple design, and good performance</li>
          <li>Developer experience and thoughtful UX</li>
          <li>Indie mindset: ship small, learn fast, iterate</li>
        </ul>
        <.now_block />
      </section>
    </div>
    """
  end

  # ── Now Page ─────────────────────────────────────────────

  def now_page(assigns) do
    ~H"""
    <h1>Now</h1>
    <p class="lead">A small snapshot of what is getting attention right now.</p>
    <hr />
    <h2>Currently Building</h2>
    <p><strong>DevPad</strong> - A lightweight toolbox for everyday developer tasks.</p>
    <h2>Learning</h2>
    <p>Elixir, Phoenix LiveView, commerce flows, and better writing habits.</p>
    <h2>Shipping</h2>
    <p>Personal brand platform MVP with product catalog and theme switching.</p>
    """
  end

  # ── Contact Page ─────────────────────────────────────────

  def contact_page(assigns) do
    ~H"""
    <h1>Contact</h1>
    <p class="lead">
      Let's connect. I'm always open to interesting conversations and collaborations.
    </p>
    <hr />
    <section>
      <h2>Email</h2>
      <p>
        <a href={"mailto:#{@profile_email}"}>{@profile_email}</a>
      </p>
    </section>
    <section>
      <h2>Social</h2>
      <ul>
        <li :for={{label, url} <- @social_links}>
          <a href={url}>{label}</a>
        </li>
      </ul>
    </section>
    <section>
      <h2>Collaboration</h2>
      <p>
        I'm interested in product collaborations, speaking opportunities, and building useful things together.
        Feel free to reach out via email or social media.
      </p>
    </section>
    """
  end

  # ── Not Found ────────────────────────────────────────────

  def not_found(assigns) do
    ~H"""
    <h1>Page Not Found</h1>
    <p>The requested page does not exist yet.</p>
    <p><a href="/">Back home</a></p>
    """
  end

  # ── Shared Components ────────────────────────────────────

  def featured_work(assigns) do
    ~H"""
    <section>
      <h2>Featured Work</h2>
      <ul class="compact-list">
        <%= if @projects == [] do %>
          <li>No featured work yet.</li>
        <% else %>
          <li :for={project <- Enum.take(@projects, 3)}>
            <a href={"/work/#{project.slug}"}>{project.title}</a>
            <p>{project.summary}</p>
            <p class="meta">
              {project.role}
              <%= if project.duration || project.year do %>
                · {project.duration || project.year}
              <% end %>
            </p>
          </li>
        <% end %>
      </ul>
      <a href="/work" class="section-link">View all work</a>
    </section>
    """
  end

  def recent_writing(assigns) do
    ~H"""
    <section>
      <h2>Recent Writing</h2>
      <ul class="compact-list">
        <%= if @posts == [] do %>
          <li>No writing published yet.</li>
        <% else %>
          <li :for={post <- @posts}>
            <a href={"/writing/#{post.slug}"}>{post.title}</a>
          </li>
        <% end %>
      </ul>
      <a href="/writing" class="section-link">View all writing</a>
    </section>
    """
  end

  def featured_products(assigns) do
    ~H"""
    <section>
      <h2>Products</h2>
      <ul class="compact-list">
        <%= if @products == [] do %>
          <li>No featured products yet.</li>
        <% else %>
          <li :for={product <- @products}>
            <a href={"/products/#{product.slug}"}>{product.title} - {product.summary}</a>
          </li>
        <% end %>
      </ul>
      <a href="/products" class="section-link">View all products</a>
    </section>
    """
  end

  def now_block(assigns) do
    ~H"""
    <section>
      <h2>Now</h2>
      <p>
        <strong>Building</strong> <a href="/now">DevPad</a>, A lightweight toolbox for everyday developer tasks.
      </p>
      <p>Personal brand platform MVP with product catalog and theme switching.</p>
    </section>
    """
  end

  def visual_frame(assigns) do
    ~H"""
    <figure class="media-frame">
      <%= if assigns[:media] do %>
        <img src={@media.url} alt={@media.alt_text || @text} />
        <figcaption>{@text}</figcaption>
      <% else %>
        <div class="mock-visual" role="img" aria-label={@text}>
          <strong>{@text}</strong>
        </div>
      <% end %>
    </figure>
    """
  end

  def detail_section(assigns) do
    ~H"""
    <section :if={present?(@body)} class="detail-section">
      <h2>{@title}</h2>
      <p>{@body}</p>
    </section>
    """
  end

  def empty_state(assigns) do
    ~H"""
    <p class="empty-state">{@text}</p>
    """
  end

  # ── Helpers ──────────────────────────────────────────────

  defp theme_class_name("simple"), do: "simple-theme"
  defp theme_class_name("us_builder"), do: "us-builder-theme"
  defp theme_class_name("premium_dark"), do: "premium-dark-theme"
  defp theme_class_name(_), do: "old-web-theme"

  defp ordered_social_links(social_links, profile_email) do
    preferred_order = ["Email", "GitHub", "LinkedIn", "X"]

    preferred_links =
      preferred_order
      |> Enum.map(fn label -> {label, Map.get(social_links, label)} end)
      |> Enum.reject(fn {_label, url} -> is_nil(url) or url == "" end)

    custom_links =
      social_links
      |> Map.drop(preferred_order)
      |> Enum.sort_by(fn {label, _url} -> label end)

    links = preferred_links ++ custom_links

    if links == [] and is_binary(profile_email) and profile_email != "" do
      [{"Email", "mailto:#{profile_email}"}]
    else
      links
    end
  end

  defp media_by_id(projects) do
    projects
    |> Enum.map(& &1.cover_image_id)
    |> Content.list_media_by_ids()
    |> Map.new(fn media -> {media.id, media} end)
  end

  defp first_project_media(projects, media_by_id) do
    projects
    |> Enum.find_value(fn project -> Map.get(media_by_id, project.cover_image_id) end)
  end

  defp work_filters do
    [
      %{key: :all, label: "All", href: "/work"},
      %{
        key: {:discipline, "ios_development"},
        label: "iOS",
        href: "/work?discipline=ios_development"
      },
      %{
        key: {:discipline, "mobile_engineering_lead"},
        label: "Mobile Lead",
        href: "/work?discipline=mobile_engineering_lead"
      },
      %{key: {:platform, "macos"}, label: "macOS", href: "/work?platform=macos"},
      %{
        key: {:discipline, "backend_engineering"},
        label: "Backend",
        href: "/work?discipline=backend_engineering"
      },
      %{
        key: {:discipline, "frontend_engineering"},
        label: "Frontend",
        href: "/work?discipline=frontend_engineering"
      },
      %{key: {:platform, "flutter"}, label: "Flutter", href: "/work?platform=flutter"},
      %{
        key: {:discipline, "fullstack_engineering"},
        label: "Full-stack",
        href: "/work?discipline=fullstack_engineering"
      }
    ]
  end

  defp work_filter_from_params(%{"discipline" => discipline}) when is_binary(discipline) do
    %{key: {:discipline, discipline}, field: :discipline, value: discipline}
  end

  defp work_filter_from_params(%{"platform" => platform}) when is_binary(platform) do
    %{key: {:platform, platform}, field: :platform, value: platform}
  end

  defp work_filter_from_params(_params), do: %{key: :all, field: nil, value: nil}

  defp active_filter_query(%{field: nil}), do: []
  defp active_filter_query(%{field: field, value: value}), do: [{field, value}]

  defp project_badges(project) do
    (project.platforms || [])
    |> Kernel.++(project.disciplines || [])
    |> Enum.map(&project_label/1)
  end

  defp project_label(value) do
    Project.label_for(value)
  end

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(value), do: not is_nil(value)

  defp format_date(nil), do: ""

  defp format_date(date) do
    month_names =
      ~w(January February March April May June July August September October November December)

    month = Enum.at(month_names, date.month - 1)
    "#{month} #{date.day}, #{date.year}"
  end

  defp format_money(product) do
    "#{product.currency} #{product.price}"
  end
end
