defmodule PersonalBrandWeb.PublicLive do
  use PersonalBrandWeb, :live_view

  alias PersonalBrand.Content
  alias PersonalBrand.Content.Post
  alias PersonalBrand.Content.Project

  # ── Mount ────────────────────────────────────────────────

  def mount(_params, _session, socket) do
    settings = Content.get_site_settings() || default_site_settings()
    theme_class = theme_class_name(settings.active_theme)

    socket =
      assign(socket,
        site_name: settings.site_name,
        profile_name: settings.profile_name || settings.site_name,
        profile_title: settings.profile_title,
        profile_bio: settings.profile_bio,
        profile_email: settings.profile_email,
        profile_location: settings.profile_location,
        support_links: support_links(settings),
        social_links: settings.social_links || %{},
        ordered_social_links:
          ordered_social_links(settings.social_links || %{}, settings.profile_email),
        active_theme: settings.active_theme,
        theme_class: theme_class,
        page_title: settings.site_name,
        settings: settings,
        page: :home,
        has_more: false,
        has_more_posts: false,
        has_more_products: false,
        work_page: 1,
        work_total: 0,
        filter_counts: %{},
        writing_page: 1,
        products_page: 1,
        search_query: "",
        search_results: nil,
        search_loading: false
      )

    {:ok, socket, layout: {PersonalBrandWeb.Layouts, :public}}
  end

  defp default_site_settings do
    %{
      site_name: "Nunu Nugraha",
      headline: "No public content has been published yet.",
      subheadline:
        "Add site settings, projects, writing, products, and media from the admin panel.",
      primary_cta_text: "View Work",
      primary_cta_url: "/work",
      secondary_cta_text: "Read Writing",
      secondary_cta_url: "/writing",
      active_theme: "old_web_classic",
      profile_name: "Nunu Nugraha",
      profile_title: "Content is ready to be configured.",
      profile_location: nil,
      profile_email: nil,
      profile_bio:
        "This site is running with an empty database. Publish profile content from admin.",
      social_links: %{},
      about_intro: nil,
      about_focus: nil,
      about_tools: [],
      about_values: [],
      now_building: nil,
      now_learning: nil,
      now_focus: nil,
      now_updated_at: nil,
      saweria_url: nil,
      buy_me_coffee_url: nil,
      tips_cta_title: nil,
      tips_cta_body: nil,
      xendit_checkout_url: nil,
      xendit_webhook_url: nil,
      featured_project_ids: [],
      featured_product_ids: []
    }
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
            cover_media = Content.get_media(project.cover_image_id)
            certificate_media = Content.get_media(project.certificate_media_id)

            {:noreply,
             assign(socket,
               page: :work_detail,
               project: project,
               cover_media: cover_media,
               certificate_media: certificate_media,
               page_title: project.title,
               meta_description: project.summary || project.description,
               og_image: cover_media && cover_media.url,
               og_type: "article"
             )}
        end

      :writing_detail ->
        case Content.get_post_by_slug(slug) do
          nil ->
            {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}

          post ->
            cover_media = Content.get_media(post.cover_image_id)
            og_media = Content.get_media(post.og_image_id) || cover_media

            {:noreply,
             assign(socket,
               page: :writing_detail,
               post: post,
               post_content_html: Post.render_content(post),
               cover_media: cover_media,
               page_title: post.seo_title || post.title,
               meta_description: post.seo_description || post.excerpt,
               og_image: og_media && og_media.url,
               og_type: "article"
             )}
        end

      :product_detail ->
        case Content.get_product_by_slug(slug) do
          nil ->
            {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}

          product ->
            {:noreply,
             assign(socket,
               page: :product_detail,
               product: product,
               page_title: product.title,
               meta_description: product.summary,
               og_type: "product"
             )}
        end

      _ ->
        {:noreply, assign(socket, page: :not_found, page_title: "Not Found")}
    end
  end

  def handle_params(params, _uri, socket) do
    path = socket.assigns.live_action
    settings = socket.assigns.settings

    socket =
      case path do
        :index ->
          projects = Content.list_featured_projects()
          posts = Content.list_posts(limit: 3)
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
          filter_opts = active_filter_query(active_filter)
          projects = Content.list_published_projects(filter_opts)
          total = Content.count_published_projects(filter_opts)
          filter_counts = work_filter_counts()

          assign(socket,
            page: :work_index,
            page_title: "Work",
            projects: projects,
            work_filters: work_filters(),
            filter_counts: filter_counts,
            active_filter: active_filter,
            project_media: media_by_id(projects),
            work_page: 1,
            work_total: total,
            has_more: total > length(projects)
          )

        :writing_index ->
          posts = Content.list_posts()
          total_posts = Content.count_published_posts()

          assign(socket,
            page: :writing_index,
            page_title: "Writing",
            posts: posts,
            writing_page: 1,
            has_more_posts: total_posts > length(posts)
          )

        :products_index ->
          products = Content.list_products()
          total_products = Content.count_published_products()

          assign(socket,
            page: :products_index,
            page_title: "Products",
            products: products,
            products_page: 1,
            has_more_products: total_products > length(products)
          )

        :about_page ->
          assign(socket, page: :about_page, page_title: "About")

        :now_page ->
          assign(socket, page: :now_page, page_title: "Now")

        :contact_page ->
          assign(socket, page: :contact_page, page_title: "Contact")

        :search ->
          query = Map.get(params, "q", "")

          results =
            if String.length(String.trim(query)) >= 2,
              do: Content.search(query),
              else: nil

          assign(socket,
            page: :search,
            page_title: "Search",
            search_query: query,
            search_results: results,
            search_loading: false
          )

        _ ->
          assign(socket, page: :not_found, page_title: "Not Found")
      end

    {:noreply, socket}
  end

  # ── Load More (Work Index) ──────────────────────────────

  def handle_event("load_more", _params, socket) do
    next_page = socket.assigns.work_page + 1
    per_page = Content.projects_per_page()
    offset = (next_page - 1) * per_page

    filter_opts =
      active_filter_query(socket.assigns.active_filter) ++
        [limit: per_page, offset: offset]

    more_projects = Content.list_published_projects(filter_opts)
    all_projects = socket.assigns.projects ++ more_projects
    new_media = media_by_id(more_projects)
    all_media = Map.merge(socket.assigns.project_media, new_media)

    total = Content.count_published_projects(active_filter_query(socket.assigns.active_filter))

    {:noreply,
     assign(socket,
       projects: all_projects,
       project_media: all_media,
       work_page: next_page,
       has_more: total > length(all_projects)
     )}
  end

  # ── Load More (Writing Index) ───────────────────────────

  def handle_event("load_more_posts", _params, socket) do
    next_page = socket.assigns.writing_page + 1
    per_page = Content.posts_per_page()
    offset = (next_page - 1) * per_page

    more_posts = Content.list_posts(limit: per_page, offset: offset)
    all_posts = socket.assigns.posts ++ more_posts
    total = Content.count_published_posts()

    {:noreply,
     assign(socket,
       posts: all_posts,
       writing_page: next_page,
       has_more_posts: total > length(all_posts)
     )}
  end

  # ── Load More (Products Index) ──────────────────────────

  def handle_event("load_more_products", _params, socket) do
    next_page = socket.assigns.products_page + 1
    per_page = Content.products_per_page()
    offset = (next_page - 1) * per_page

    more_products = Content.list_products(limit: per_page, offset: offset)
    all_products = socket.assigns.products ++ more_products
    total = Content.count_published_products()

    {:noreply,
     assign(socket,
       products: all_products,
       products_page: next_page,
       has_more_products: total > length(all_products)
     )}
  end

  # ── Search ──────────────────────────────────────────────

  def handle_event("live_search", %{"q" => query}, socket) do
    results =
      if String.length(String.trim(query)) >= 2,
        do: Content.search(query),
        else: nil

    {:noreply,
     assign(socket,
       search_query: query,
       search_results: results,
       search_loading: false
     )}
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
          filter_counts={@filter_counts}
          active_filter={@active_filter}
          has_more={@has_more}
          total={@work_total}
        />
      <% :work_detail -> %>
        <.work_detail
          project={@project}
          cover_media={@cover_media}
          certificate_media={@certificate_media}
          profile_email={@profile_email}
        />
      <% :writing_index -> %>
        <.writing_index posts={@posts} has_more={@has_more_posts} />
      <% :writing_detail -> %>
        <.writing_detail
          post={@post}
          post_content_html={@post_content_html}
          support_links={@support_links}
          tips_cta_title={@settings.tips_cta_title}
          tips_cta_body={@settings.tips_cta_body}
        />
      <% :products_index -> %>
        <.products_index products={@products} has_more={@has_more_products} />
      <% :product_detail -> %>
        <.product_detail product={@product} />
      <% :about_page -> %>
        <.about_page settings={@settings} />
      <% :now_page -> %>
        <.now_page settings={@settings} />
      <% :contact_page -> %>
        <.contact_page
          profile_email={@profile_email}
          social_links={@ordered_social_links}
          support_links={@support_links}
        />
      <% :search -> %>
        <.search_page
          query={@search_query}
          results={@search_results}
          loading={@search_loading}
        />
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
        <.now_block settings={@settings} />
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
    assigns =
      assigns
      |> assign(:featured_projects, featured_projects(assigns.projects))
      |> assign(:regular_projects, regular_projects(assigns.projects))
      |> assign(:is_filtered, assigns.active_filter.key != :all)
      |> assign(:showing_count, length(assigns.projects))

    ~H"""
    <h1>Work</h1>
    <p>Project portfolio untuk menunjukkan ownership, technical depth, dan impact.</p>
    <nav class="tag-list" aria-label="Work filters">
      <a
        :for={filter <- @filters}
        href={filter.href}
        class={if filter.key == @active_filter.key, do: "tag active", else: "tag"}
      >
        {filter.label} ({Map.get(@filter_counts, filter.key, 0)})
      </a>
    </nav>
    <hr />
    <div class="detail-grid">
      <section>
        <%= if @projects == [] do %>
          <%= if @is_filtered do %>
            <.empty_state_filtered filter_label={filter_label(@active_filter)} />
          <% else %>
            <.empty_state_no_projects />
          <% end %>
        <% end %>
        <%= if @featured_projects != [] do %>
          <h2>Featured Projects</h2>
          <.work_project_item :for={project <- @featured_projects} project={project} />
        <% end %>
        <%= if @regular_projects != [] do %>
          <h2>{if @featured_projects == [], do: "Projects", else: "Other Projects"}</h2>
          <.work_project_item :for={project <- @regular_projects} project={project} />
        <% end %>
        <p :if={@showing_count > 0} class="meta">
          Menampilkan {@showing_count} dari {@total} project
        </p>
        <div :if={@has_more} class="load-more">
          <button phx-click="load_more" phx-disable-with="Loading...">
            Load more projects
          </button>
        </div>
      </section>
      <.visual_frame
        text="Project screenshots live here."
        media={first_project_media(@projects, @project_media)}
      />
    </div>
    """
  end

  def work_project_item(assigns) do
    ~H"""
    <article class="item">
      <div class="item-title">
        <a href={"/work/#{@project.slug}"}>{@project.title}</a>
      </div>
      <p>{@project.summary}</p>
      <p :if={@project.impact_summary} class="lead">{@project.impact_summary}</p>
      <p class="meta">
        {@project.role}
        <%= if @project.duration || @project.year do %>
          · {@project.duration || @project.year}
        <% end %>
      </p>
      <div class="tag-list">
        <span :for={badge <- project_badges(@project)} class="tag">{badge}</span>
      </div>
      <div :if={list_present?(@project.tech_stack)} class="stack-preview">
        <span :for={tech <- stack_preview(@project.tech_stack)}>{tech}</span>
        <span :if={stack_overflow_count(@project.tech_stack) > 0}>
          +{stack_overflow_count(@project.tech_stack)} more
        </span>
      </div>
    </article>
    """
  end

  # ── Work Detail ──────────────────────────────────────────

  def work_detail(assigns) do
    ~H"""
    <p class="breadcrumb"><a href="/work">Work</a> / {@project.title}</p>
    <div class="case-study-layout">
      <article class="case-study">
        <h1>{@project.title}</h1>
        <p :if={present?(@project.summary)} class="tagline">{@project.summary}</p>

        <dl class="project-facts" aria-label="Project facts">
          <div>
            <dt>Role</dt>
            <dd>{@project.role || "Contributor"}</dd>
          </div>
          <div>
            <dt>Ownership</dt>
            <dd>{@project.ownership || "Case study contributor"}</dd>
          </div>
          <div :if={@project.company}>
            <dt>Company</dt>
            <dd>{@project.company}</dd>
          </div>
          <div :if={@project.client}>
            <dt>Client</dt>
            <dd>{@project.client}</dd>
          </div>
          <div :if={@project.team_size}>
            <dt>Team</dt>
            <dd>{@project.team_size}</dd>
          </div>
          <div>
            <dt>Period</dt>
            <dd>{@project.duration || @project.year || "Not specified"}</dd>
          </div>
          <div :if={project_badges(@project) != []}>
            <dt>Focus</dt>
            <dd>{Enum.join(project_badges(@project), ", ")}</dd>
          </div>
        </dl>

        <p :if={@project.case_study_visibility in ["limited", "private_summary"]} class="notice">
          Some implementation details are summarized to respect proprietary project boundaries.
        </p>
        <.detail_section title="Overview" body={@project.description} />
        <section :if={list_present?(@project.tech_stack)} class="detail-section">
          <h2>Tech & Libraries</h2>
          <p>
            Teknologi dan library yang dipakai atau disentuh di project ini:
          </p>
          <div class="tech-list">
            <span :for={tech <- list_value(@project.tech_stack)}>{tech}</span>
          </div>
        </section>
        <.detail_section title="Problem" body={@project.problem} />
        <.detail_section title="My Role & Ownership" body={@project.ownership} />
        <.detail_section title="Technical Approach" body={@project.solution} />
        <.detail_section title="Architecture Notes" body={@project.architecture_notes} />
        <.detail_section title="Trade-offs" body={@project.tradeoffs} />
        <section :if={list_present?(@project.technical_highlights)} class="detail-section">
          <h2>Implementation Highlights</h2>
          <ul class="evidence-list">
            <li :for={item <- list_value(@project.technical_highlights)}>{item}</li>
          </ul>
        </section>
        <section :if={project_results?(@project)} class="detail-section">
          <h2>Results</h2>
          <ul class="evidence-list">
            <li :if={@project.impact_summary}>{@project.impact_summary}</li>
            <li :for={item <- list_value(@project.result)}>{item}</li>
            <li :for={item <- list_value(@project.metrics)}>{item}</li>
          </ul>
        </section>
        <section :if={project_links?(@project)} class="detail-section">
          <h2>Links</h2>
          <ul>
            <li :if={@project.demo_url}><a href={@project.demo_url}>Live Demo</a></li>
            <li :if={@project.demo_video_url}>
              <a href={@project.demo_video_url}>Video Demo</a>
            </li>
            <li :if={public_github_link?(@project)}>
              <a href={@project.github_url} target="_blank" rel="noopener noreferrer">
                GitHub Repository
              </a>
            </li>
            <li :if={private_github_link?(@project)}>
              <a href={github_access_request_url(@profile_email, @project)}>
                GitHub — request access
              </a>
            </li>
            <li :if={@project.app_store_url}><a href={@project.app_store_url}>App Store</a></li>
            <li :if={@certificate_media}>
              <a href={@certificate_media.url} download target="_blank" rel="noopener noreferrer">
                Download Certificate
              </a>
            </li>
          </ul>
        </section>
        <section :if={direct_video_url?(@project.demo_video_url)} class="detail-section">
          <h2>Video Demo</h2>
          <video class="demo-video" controls preload="metadata">
            <source src={@project.demo_video_url} />
            <a href={@project.demo_video_url}>Open video demo</a>
          </video>
        </section>
      </article>
      <aside class="case-study-side">
        <.visual_frame text={"#{@project.title} case study"} media={@cover_media} />
      </aside>
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
    <div :if={@has_more} class="load-more">
      <button phx-click="load_more_posts" phx-disable-with="Loading...">
        Load more writing
      </button>
    </div>
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
        {Phoenix.HTML.raw(@post_content_html)}
      </div>
      <section :if={@support_links != []} class="post-support">
        <h2>{@tips_cta_title || "Support this writing"}</h2>
        <p :if={present?(@tips_cta_body)}>{@tips_cta_body}</p>
        <p class="cta-row">
          <a
            :for={{label, url} <- @support_links}
            href={url}
            class="button-link"
            target="_blank"
            rel="noopener noreferrer"
          >
            {label}
          </a>
        </p>
      </section>
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
    <div :if={@has_more} class="load-more">
      <button phx-click="load_more_products" phx-disable-with="Loading...">
        Load more products
      </button>
    </div>
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
            <li :for={item <- list_value(@product.included)}>{item}</li>
          </ul>
        </section>
        <section :if={map_present?(@product.faq)} class="detail-section">
          <h2>FAQ</h2>
          <%= for {question, answer} <- map_value(@product.faq) do %>
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
    assigns =
      assigns
      |> assign(:intro, assigns.settings.about_intro || assigns.settings.profile_bio)
      |> assign(:focus, assigns.settings.about_focus)
      |> assign(:tools, list_value(assigns.settings.about_tools))
      |> assign(:values, list_value(assigns.settings.about_values))

    ~H"""
    <div class="detail-grid">
      <section>
        <h1>About</h1>
        <p :if={present?(@intro)}>{@intro}</p>
        <p :if={!present?(@intro)}>
          Profile details have not been published yet.
        </p>
      </section>
      <.visual_frame text="Handmade but useful." />
    </div>
    <hr />
    <div class="two-col">
      <section :if={present?(@focus) or @tools != []}>
        <h2>What I Do</h2>
        <p :if={present?(@focus)}>{@focus}</p>
        <section :if={@tools != []}>
          <h2>Tools I Use</h2>
          <ul>
            <li :for={tool <- @tools}>{tool}</li>
          </ul>
        </section>
      </section>
      <section>
        <section :if={@values != []}>
          <h2>What I Care About</h2>
          <ul>
            <li :for={value <- @values}>{value}</li>
          </ul>
        </section>
        <.now_block settings={@settings} />
      </section>
    </div>
    """
  end

  # ── Now Page ─────────────────────────────────────────────

  def now_page(assigns) do
    assigns =
      assigns
      |> assign(:building, assigns.settings.now_building)
      |> assign(:learning, assigns.settings.now_learning)
      |> assign(:focus, assigns.settings.now_focus)
      |> assign(:updated_at, assigns.settings.now_updated_at)

    ~H"""
    <h1>Now</h1>
    <p class="lead">A small snapshot of what is getting attention right now.</p>
    <p :if={@updated_at} class="meta">Updated {format_date(@updated_at)}</p>
    <hr />
    <section :if={present?(@building)}>
      <h2>Currently Building</h2>
      <p>{@building}</p>
    </section>
    <section :if={present?(@learning)}>
      <h2>Learning</h2>
      <p>{@learning}</p>
    </section>
    <section :if={present?(@focus)}>
      <h2>Focus</h2>
      <p>{@focus}</p>
    </section>
    <p :if={!present?(@building) and !present?(@learning) and !present?(@focus)}>
      No current update has been published yet.
    </p>
    """
  end

  # ── Contact Page ─────────────────────────────────────────

  def contact_page(assigns) do
    assigns = assign(assigns, :social_links, non_email_social_links(assigns.social_links))

    ~H"""
    <h1>Contact</h1>
    <p class="lead">
      I am open to remote Flutter Developer roles, mobile app work, and practical product collaborations.
    </p>
    <hr />
    <section>
      <h2>Email</h2>
      <p>
        <%= if present?(@profile_email) do %>
          <a href={"mailto:#{@profile_email}"}>{@profile_email}</a>
        <% else %>
          No public email has been configured yet.
        <% end %>
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
    <section :if={@support_links != []}>
      <h2>Support</h2>
      <ul>
        <li :for={{label, url} <- @support_links}>
          <a href={url}>{label}</a>
        </li>
      </ul>
    </section>
    <section>
      <h2>Collaboration</h2>
      <p>
        Best fit: Flutter apps, mobile product engineering, iOS/Android conversations, and small useful products
        that need someone who can move from idea to shipped implementation. Email is the best way to reach me.
      </p>
    </section>
    """
  end

  # ── Search Page ───────────────────────────────────────────

  def search_page(assigns) do
    assigns =
      assigns
      |> assign(:has_results, has_search_results?(assigns.results))
      |> assign(:total_count, search_total_count(assigns.results))

    ~H"""
    <section class="search-page">
      <h1>Search</h1>
      <p>Cari project, tulisan, atau produk di seluruh website.</p>
      <form phx-change="live_search" phx-submit="live_search" class="search-form">
        <input
          type="text"
          name="q"
          value={@query}
          placeholder="Ketik minimal 2 karakter..."
          phx-debounce="300"
          autocomplete="off"
          class="search-input"
          autofocus
        />
      </form>

      <div :if={@loading} class="search-loading" aria-label="Searching">
        <span class="dot"></span>
        <span class="dot"></span>
        <span class="dot"></span>
      </div>

      <%= if @results && @has_results do %>
        <p class="meta search-meta">{@total_count} hasil ditemukan</p>

        <section :if={@results.projects != []} class="search-group">
          <h2>Projects ({length(@results.projects)})</h2>
          <article :for={project <- @results.projects} class="item">
            <div class="item-title"><a href={"/work/#{project.slug}"}>{project.title}</a></div>
            <p>{project.summary}</p>
            <p class="meta">{project.role} · {project.duration || project.year}</p>
          </article>
        </section>

        <section :if={@results.posts != []} class="search-group">
          <h2>Writing ({length(@results.posts)})</h2>
          <article :for={post <- @results.posts} class="item">
            <div class="item-title"><a href={"/writing/#{post.slug}"}>{post.title}</a></div>
            <p>{post.excerpt}</p>
            <p class="meta">{format_date(post.published_at)} · {post.reading_time} min read</p>
          </article>
        </section>

        <section :if={@results.products != []} class="search-group">
          <h2>Products ({length(@results.products)})</h2>
          <article :for={product <- @results.products} class="item">
            <div class="item-title"><a href={"/products/#{product.slug}"}>{product.title}</a></div>
            <p>{product.summary}</p>
          </article>
        </section>
      <% end %>

      <div :if={@results && !@has_results} class="empty-state">
        <p><strong>Tidak ada hasil untuk "{@query}"</strong></p>
        <p>
          Coba kata kunci lain atau lihat <a href="/work">Work</a>
          · <a href="/writing">Writing</a>
          · <a href="/products">Products</a>
        </p>
      </div>

      <div :if={!@results && @query == ""} class="search-suggestions">
        <p>Coba cari:</p>
        <div class="tag-list">
          <a href="/search?q=Flutter" class="tag">Flutter</a>
          <a href="/search?q=iOS" class="tag">iOS</a>
          <a href="/search?q=Phoenix" class="tag">Phoenix</a>
          <a href="/search?q=Architecture" class="tag">Architecture</a>
          <a href="/search?q=API" class="tag">API</a>
        </div>
      </div>
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
            <p>{post.excerpt}</p>
            <p class="meta">
              {format_date(post.published_at)} · {post.reading_time} min read
            </p>
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
    assigns =
      assigns
      |> assign(:building, assigns.settings.now_building)
      |> assign(:focus, assigns.settings.now_focus)

    ~H"""
    <section :if={present?(@building) or present?(@focus)}>
      <h2>Now</h2>
      <p :if={present?(@building)}><strong>Building</strong> {@building}</p>
      <p :if={present?(@focus)}>{@focus}</p>
      <p><a href="/now">View current focus</a></p>
    </section>
    """
  end

  def visual_frame(assigns) do
    ~H"""
    <figure class="media-frame">
      <%= if assigns[:media] do %>
        <%= if video_media?(@media) do %>
          <video controls preload="metadata">
            <source src={@media.url} type={@media.content_type} />
            <a href={@media.url}>Open media</a>
          </video>
        <% else %>
          <img src={@media.url} alt={@media.alt_text || @text} />
        <% end %>
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
    assigns = assign(assigns, :blocks, detail_blocks(assigns[:body]))

    ~H"""
    <section :if={@blocks != []} class="detail-section">
      <h2>{@title}</h2>
      <%= for block <- @blocks do %>
        <p :if={block.type == :paragraph}>{block.text}</p>
        <ol :if={block.type == :ordered_list} class="detail-ordered-list">
          <li :for={item <- block.items}>{item}</li>
        </ol>
      <% end %>
    </section>
    """
  end

  def empty_state(assigns) do
    ~H"""
    <p class="empty-state">{@text}</p>
    """
  end

  def empty_state_no_projects(assigns) do
    ~H"""
    <div class="empty-state">
      <p><strong>Portfolio coming soon.</strong></p>
      <p>Projects are being documented and will be published shortly.</p>
      <p>Check back soon or <a href="/contact">get in touch</a> for early access.</p>
    </div>
    """
  end

  def empty_state_filtered(assigns) do
    ~H"""
    <div class="empty-state">
      <p><strong>No projects found for {@filter_label}.</strong></p>
      <p><a href="/work">View all projects</a> or try a different filter.</p>
    </div>
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
    |> Enum.reject(&is_nil/1)
    |> Content.list_media_by_ids()
    |> Map.new(fn media -> {media.id, media} end)
  end

  defp first_project_media(projects, media_by_id) do
    projects
    |> Enum.find_value(fn project -> Map.get(media_by_id, project.cover_image_id) end)
  end

  defp featured_projects(projects), do: Enum.filter(projects, & &1.featured)
  defp regular_projects(projects), do: Enum.reject(projects, & &1.featured)

  defp work_filters do
    [
      %{key: :all, label: "All", href: "/work"},
      %{
        key: {:discipline, "mobile_developer"},
        label: "Mobile",
        href: "/work?discipline=mobile_developer"
      },
      %{
        key: {:discipline, "flutter_developer"},
        label: "Flutter",
        href: "/work?discipline=flutter_developer"
      },
      %{
        key: {:discipline, "ios_developer"},
        label: "iOS",
        href: "/work?discipline=ios_developer"
      },
      %{
        key: {:discipline, "swift"},
        label: "Swift",
        href: "/work?discipline=swift"
      },
      %{
        key: {:discipline, "kotlin"},
        label: "Kotlin",
        href: "/work?discipline=kotlin"
      },
      %{
        key: {:discipline, "android_developer"},
        label: "Android",
        href: "/work?discipline=android_developer"
      },
      %{
        key: {:discipline, "backend_developer"},
        label: "Backend",
        href: "/work?discipline=backend_developer"
      },
      %{
        key: {:discipline, "frontend_developer"},
        label: "Frontend",
        href: "/work?discipline=frontend_developer"
      },
      %{
        key: {:discipline, "fullstack_developer"},
        label: "Full-Stack",
        href: "/work?discipline=fullstack_developer"
      },
      %{
        key: {:discipline, "ai_automation"},
        label: "AI Automation",
        href: "/work?discipline=ai_automation"
      },
      %{
        key: {:discipline, "cli_tooling"},
        label: "CLI & Tooling",
        href: "/work?discipline=cli_tooling"
      }
    ]
  end

  defp work_filter_counts do
    all = Content.count_published_projects([])

    counts =
      work_filters()
      |> Enum.map(fn filter ->
        count =
          case filter.key do
            :all -> all
            {:discipline, d} -> Content.count_published_projects(discipline: d)
            {:platform, p} -> Content.count_published_projects(platform: p)
          end

        {filter.key, count}
      end)
      |> Map.new()

    counts
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

  defp filter_label(%{key: :all}), do: "All Projects"

  defp filter_label(%{key: {:discipline, value}}) do
    Project.label_for(value)
  end

  defp filter_label(%{key: {:platform, value}}) do
    Project.label_for(value)
  end

  defp filter_label(_), do: "this filter"

  defp present?(value) when is_binary(value), do: String.trim(value) != ""
  defp present?(value), do: not is_nil(value)

  defp has_search_results?(nil), do: false

  defp has_search_results?(results) do
    results.projects != [] or results.posts != [] or results.products != []
  end

  defp search_total_count(nil), do: 0

  defp search_total_count(results) do
    length(results.projects) + length(results.posts) + length(results.products)
  end

  defp list_value(value) when is_list(value), do: value
  defp list_value(_value), do: []

  defp list_present?(value), do: list_value(value) != []

  defp stack_preview(value), do: value |> list_value() |> Enum.take(8)

  defp stack_overflow_count(value) do
    count = value |> list_value() |> length()
    max(count - 8, 0)
  end

  defp detail_blocks(value) when is_binary(value) do
    value
    |> String.split(~r/\n{2,}/, trim: true)
    |> Enum.flat_map(&detail_paragraph_blocks/1)
  end

  defp detail_blocks(_value), do: []

  defp detail_paragraph_blocks(value) do
    value = String.trim(value)

    cond do
      value == "" ->
        []

      Regex.match?(~r/(^|\s)\d+\.\s+/, value) ->
        numbered_blocks(value)

      String.length(value) > 420 ->
        value
        |> sentence_chunks()
        |> Enum.map(&%{type: :paragraph, text: &1})

      true ->
        [%{type: :paragraph, text: value}]
    end
  end

  defp numbered_blocks(value) do
    parts = Regex.split(~r/\s+(?=\d+\.\s+)/, value, trim: true)

    {intro, numbered_parts} =
      case parts do
        [first | rest] ->
          if Regex.match?(~r/^\d+\.\s+/, first), do: {nil, parts}, else: {first, rest}

        [] ->
          {nil, []}
      end

    items =
      numbered_parts
      |> Enum.map(&String.replace(&1, ~r/^\d+\.\s+/, ""))
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    []
    |> maybe_add_intro(intro)
    |> maybe_add_ordered_list(items)
  end

  defp maybe_add_intro(blocks, intro) when is_binary(intro) and intro != "" do
    blocks ++ [%{type: :paragraph, text: intro}]
  end

  defp maybe_add_intro(blocks, _intro), do: blocks

  defp maybe_add_ordered_list(blocks, items) when items != [] do
    blocks ++ [%{type: :ordered_list, items: items}]
  end

  defp maybe_add_ordered_list(blocks, _items), do: blocks

  defp sentence_chunks(value) do
    value
    |> String.split(~r/(?<=[.!?])\s+/, trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(&Enum.join(&1, " "))
  end

  defp project_results?(project) do
    present?(project.impact_summary) or list_present?(project.result) or
      list_present?(project.metrics)
  end

  defp project_links?(project) do
    Enum.any?(
      [
        project.demo_url,
        project.demo_video_url,
        project.github_url,
        project.app_store_url,
        project.certificate_media_id
      ],
      &present?/1
    )
  end

  defp public_github_link?(project),
    do: present?(project.github_url) and project.case_study_visibility == "public"

  defp private_github_link?(project),
    do: present?(project.github_url) and project.case_study_visibility != "public"

  defp github_access_request_url(profile_email, project)
       when is_binary(profile_email) and profile_email != "" do
    subject = URI.encode_query(%{subject: "GitHub access request: #{project.title}"})

    body =
      URI.encode_query(%{
        body:
          "Hi Nunu,\n\nI would like to request access to the GitHub repository for #{project.title}.\n\nThanks."
      })

    "mailto:#{profile_email}?#{subject}&#{body}"
  end

  defp github_access_request_url(_profile_email, _project), do: "/contact"

  defp non_email_social_links(social_links) do
    Enum.reject(social_links, fn {label, _url} -> String.downcase(to_string(label)) == "email" end)
  end

  defp video_media?(%{content_type: content_type, url: url}) do
    (is_binary(content_type) and String.starts_with?(content_type, "video/")) or
      direct_video_url?(url)
  end

  defp video_media?(_media), do: false

  defp direct_video_url?(url) when is_binary(url) do
    path =
      url
      |> URI.parse()
      |> Map.get(:path)
      |> to_string()
      |> String.downcase()

    String.ends_with?(path, [".mp4", ".webm", ".ogg", ".mov"])
  end

  defp direct_video_url?(_url), do: false

  defp map_value(value) when is_map(value), do: value
  defp map_value(_value), do: %{}

  defp map_present?(value), do: map_value(value) != %{}

  defp support_links(settings) do
    [
      {"Saweria", settings.saweria_url},
      {"Buy Me Coffee", settings.buy_me_coffee_url}
    ]
    |> Enum.filter(fn {_label, url} -> present?(url) end)
  end

  defp format_date(nil), do: ""

  defp format_date(date) do
    month_names =
      ~w(January February March April May June July August September October November December)

    month = Enum.at(month_names, date.month - 1)
    "#{month} #{date.day}, #{date.year}"
  end

  defp format_money(product) do
    price = if product.price, do: product.price, else: "TBD"
    currency = product.currency || ""
    String.trim("#{currency} #{price}")
  end
end
