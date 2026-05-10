defmodule PersonalBrandWeb.PublicLive do
  use PersonalBrandWeb, :live_view

  alias PersonalBrand.Content

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
        project = Content.get_project_by_slug!(slug)

        {:noreply,
         assign(socket, page: :work_detail, project: project, page_title: project.title)}

      :writing_detail ->
        post = Content.get_post_by_slug!(slug)
        {:noreply, assign(socket, page: :writing_detail, post: post, page_title: post.title)}

      :product_detail ->
        product = Content.get_product_by_slug!(slug)

        {:noreply,
         assign(socket, page: :product_detail, product: product, page_title: product.title)}

      _ ->
        {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}
    end
  end

  def handle_params(_params, _uri, socket) do
    path = socket.assigns.live_action

    socket =
      case path do
        :index ->
          settings = socket.assigns.settings
          projects = Content.list_featured_projects()
          posts = Content.list_featured_posts()
          products = Content.list_featured_products()

          assign(socket,
            page: :home,
            page_title: "Home",
            projects: projects,
            posts: posts,
            products: products,
            settings: settings
          )

        :work_index ->
          projects = Content.list_published_projects()
          assign(socket, page: :work_index, page_title: "Work", projects: projects)

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
        <.homepage settings={@settings} projects={@projects} posts={@posts} products={@products} />
      <% :work_index -> %>
        <.work_index projects={@projects} />
      <% :work_detail -> %>
        <.work_detail project={@project} />
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
      <p>
        <a href={@settings.primary_cta_url}>{@settings.primary_cta_text}</a>
        <a href={@settings.secondary_cta_url}>{@settings.secondary_cta_text}</a>
      </p>
    </section>
    <hr />
    <section>
      <h2>Start Here</h2>
      <p>
        <a href="/work">Browse work</a>
        | <a href="/writing">Read writing</a>
        | <a href="/products">See products</a>
        | <a href="/about">About Nunu</a>
        | <a href="/now">Now</a>
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
      <.visual_frame text="Ship small. Learn fast." />
    </div>
    """
  end

  # ── Work Index ───────────────────────────────────────────

  def work_index(assigns) do
    ~H"""
    <h1>Work</h1>
    <p>Selected apps, experiments, and product work.</p>
    <hr />
    <div class="detail-grid">
      <section>
        <%= for project <- @projects do %>
          <article class="item">
            <div class="item-title">
              <a href={"/work/#{project.slug}"}>{project.title} - {project.summary}</a>
            </div>
            <p>{project.description}</p>
            <p class="meta">{project.year} · {Enum.join(project.tech_stack, ", ")}</p>
          </article>
        <% end %>
      </section>
      <.visual_frame text="Project screenshots live here." />
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
          <strong>Stack:</strong> {Enum.join(@project.tech_stack, ", ")}<br />
          <strong>Year:</strong> {@project.year}<br />
          <strong>Status:</strong> {@project.status}
        </p>
        <.detail_section title="Overview" body={@project.description} />
        <.detail_section title="Problem" body={@project.problem} />
        <.detail_section title="Solution" body={@project.solution} />
        <section class="detail-section">
          <h2>Outcome</h2>
          <ul>
            <li :for={item <- @project.result}>{item}</li>
          </ul>
        </section>
        <section class="detail-section">
          <h2>Links</h2>
          <ul>
            <li :if={@project.demo_url}><a href={@project.demo_url}>Live Demo</a></li>
            <li :if={@project.github_url}><a href={@project.github_url}>GitHub</a></li>
          </ul>
        </section>
      </article>
      <.visual_frame text={"#{@project.title} case study"} />
    </div>
    """
  end

  # ── Writing Index ────────────────────────────────────────

  def writing_index(assigns) do
    ~H"""
    <h1>Writing</h1>
    <p>Builder notes, Flutter lessons, product thinking, and short essays.</p>
    <hr />
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
      <p>{@post.content_html}</p>
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
        <p><a href={@product.checkout_url} class="button-link">Buy Now</a></p>
        <div class="notice">
          This is still dummy UI. Later, this button can call Phoenix to create an order and Midtrans transaction.
        </div>
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
      <ul>
        <li :for={project <- @projects}>
          <a href={"/work/#{project.slug}"}>{project.title} - {project.summary}</a>
        </li>
      </ul>
      <a href="/work" class="section-link">View all work</a>
    </section>
    """
  end

  def recent_writing(assigns) do
    ~H"""
    <section>
      <h2>Recent Writing</h2>
      <ul>
        <li :for={post <- @posts}>
          <a href={"/writing/#{post.slug}"}>{post.title}</a>
        </li>
      </ul>
      <a href="/writing" class="section-link">View all writing</a>
    </section>
    """
  end

  def featured_products(assigns) do
    ~H"""
    <section>
      <h2>Products</h2>
      <ul>
        <li :for={product <- @products}>
          <a href={"/products/#{product.slug}"}>{product.title} - {product.summary}</a>
        </li>
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
      <div class="mock-visual" role="img" aria-label={@text}>
        <strong>{@text}</strong>
      </div>
    </figure>
    """
  end

  def detail_section(assigns) do
    ~H"""
    <section class="detail-section">
      <h2>{@title}</h2>
      <p>{@body}</p>
    </section>
    """
  end

  # ── Helpers ──────────────────────────────────────────────

  defp theme_class_name("simple"), do: "simple-theme"
  defp theme_class_name("us_builder"), do: "us-builder-theme"
  defp theme_class_name("premium_dark"), do: "premium-dark-theme"
  defp theme_class_name(_), do: "old-web-theme"

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
