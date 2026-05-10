const data = {
  profile: {
    name: "Nunu Nugraha",
    title: "Flutter Developer, Builder, and Tech Enthusiast",
    location: "Indonesia",
    email: "hello@nununugraha.dev",
    bio:
      "I build cross-platform mobile apps with Flutter, care about clean design and smooth performance, and share the lessons learned while shipping small useful products.",
    socials: [
      ["GitHub", "https://github.com/nununugraha"],
      ["X", "https://x.com/nununugraha"],
      ["LinkedIn", "https://linkedin.com"],
      ["Email", "mailto:hello@nununugraha.dev"]
    ]
  },
  siteSettings: {
    siteName: "Nunu Nugraha",
    activeTheme: "old_web_classic",
    headline: "A personal basecamp for work, writing, products, and things currently being built.",
    subheadline:
      "One data source, many homepage themes. This dummy UI is ready to be wired to Phoenix, Supabase, and future commerce flows.",
    primaryCtaText: "View Work",
    primaryCtaUrl: "/work",
    secondaryCtaText: "Read Writing",
    secondaryCtaUrl: "/writing"
  },
  themes: [
    {
      key: "old_web_classic",
      name: "Old Web Classic",
      description: "Text-first, handmade, serif, blue links, and horizontal rules."
    },
    {
      key: "simple",
      name: "Simple",
      description: "Clean, light, and easier to read for a general audience."
    },
    {
      key: "us_builder",
      name: "US Builder",
      description: "Bolder builder positioning for shipping in public."
    },
    {
      key: "premium_dark",
      name: "Premium Dark",
      description: "Developer aesthetic for apps, case studies, and products."
    }
  ],
  projects: [
    {
      title: "HabitKit",
      slug: "habitkit",
      summary: "Minimal habit tracker for iOS and Android.",
      description:
        "A clean, offline-first habit tracker with streaks, notes, calendar view, and simple analytics.",
      problem:
        "Most habit apps become too complex. HabitKit keeps the daily flow fast, clear, and motivating.",
      solution:
        "Focus on the core loop: track habits, stay consistent, see progress, and sync across devices.",
      result: ["1,000+ downloads in the first month", "4.8 average rating", "70%+ day-7 retention"],
      role: "Product Engineer",
      techStack: ["Flutter", "Supabase", "SQLite"],
      year: "2025",
      status: "published",
      featured: true,
      demoUrl: "https://example.com",
      githubUrl: "https://github.com"
    },
    {
      title: "SplitWise++",
      slug: "splitwise-plus",
      summary: "Smart group expense splitter.",
      description: "Split expenses with friends, settle up faster, and track balances effortlessly.",
      problem: "Group spending gets messy when everyone pays at different times.",
      solution: "A simple ledger with smart settlement suggestions and shareable group summaries.",
      result: ["Prototype tested with travel groups", "Reduced manual settlement steps"],
      role: "Flutter Developer",
      techStack: ["Flutter", "Firebase", "Cloud Functions"],
      year: "2024",
      status: "published",
      featured: true,
      demoUrl: "https://example.com"
    },
    {
      title: "PromptBoard",
      slug: "promptboard",
      summary: "Prompt snippets for AI builders.",
      description: "Organize, version, and reuse prompts across LLM workflows.",
      problem: "Good prompts get scattered across notes, chats, and docs.",
      solution: "A small library for prompts, variables, tags, and shareable collections.",
      result: ["Used as daily internal tool", "Prepared for productized beta"],
      role: "Builder",
      techStack: ["Flutter", "Hive", "GitHub Gist API"],
      year: "2024",
      status: "published",
      featured: true,
      githubUrl: "https://github.com"
    }
  ],
  posts: [
    {
      title: "Building a Production-Ready Flutter App in 2026",
      slug: "production-ready-flutter-2026",
      excerpt: "The checklist I use before taking a Flutter app from prototype to shipped product.",
      content:
        "A production-ready app is less about one big framework choice and more about dozens of small decisions: routing, state boundaries, offline data, observability, release process, and boring reliability.",
      tags: ["Flutter", "Shipping"],
      publishedAt: "2026-04-20",
      readingTime: 7
    },
    {
      title: "Offline-First is a Feature, Not a Fallback",
      slug: "offline-first-feature",
      excerpt: "Why local-first behavior can make everyday mobile apps feel calmer and faster.",
      content:
        "Offline-first product design starts with respect for the user's context. Network access should improve the app, not become the thing holding the app hostage.",
      tags: ["Product", "Mobile"],
      publishedAt: "2026-03-16",
      readingTime: 5
    },
    {
      title: "Design Systems for Indie Developers",
      slug: "design-systems-indie-developers",
      excerpt: "A practical way to keep small apps visually consistent without drowning in process.",
      content:
        "A tiny design system can be a folder of tokens, reusable components, and clear defaults. The point is speed with consistency, not ceremony.",
      tags: ["Design", "Flutter"],
      publishedAt: "2026-02-25",
      readingTime: 6
    }
  ],
  products: [
    {
      title: "Flux Icons",
      slug: "flux-icons",
      summary: "Clean and consistent icon set for Flutter apps.",
      description:
        "A lightweight icon pack for indie developers who need clean symbols that look good in real products.",
      productType: "digital",
      price: 29,
      currency: "USD",
      stockStatus: "in_stock",
      deliveryType: "digital_download",
      checkoutUrl: "https://app.midtrans.com/payment-link/demo",
      featured: true,
      included: ["240+ icons", "Flutter-ready package", "Figma source", "Lifetime updates for v1"],
      faq: [
        ["Can I use it commercially?", "Yes, the starter license allows use in your own apps."],
        ["Is checkout already integrated?", "For MVP this button goes to an external payment link."]
      ]
    },
    {
      title: "SnipKit",
      slug: "snipkit",
      summary: "Useful UI and code snippets for Flutter builders.",
      description:
        "A practical snippet library for common product screens, empty states, settings pages, and app utilities.",
      productType: "digital",
      price: 19,
      currency: "USD",
      stockStatus: "preorder",
      deliveryType: "digital_download",
      checkoutUrl: "https://app.midtrans.com/payment-link/demo",
      featured: true,
      included: ["Flutter snippets", "Copy-ready patterns", "Usage notes"],
      faq: [["When is it shipping?", "The first version is planned after the platform MVP is live."]]
    }
  ],
  now: {
    building: "DevPad",
    body: "A lightweight toolbox for everyday developer tasks.",
    learning: "Elixir, Phoenix LiveView, commerce flows, and better writing habits.",
    shipping: "Personal brand platform MVP with product catalog and theme switching."
  }
};

const app = document.querySelector("#app");
const state = {
  activeTheme: localStorage.getItem("active_theme") || data.siteSettings.activeTheme
};

const navItems = [
  ["Home", "/"],
  ["Work", "/work"],
  ["Writing", "/writing"],
  ["Products", "/products"],
  ["About", "/about"],
  ["Now", "/now"],
  ["Admin", "/admin"]
];

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function link(label, href, className = "") {
  return `<a ${className ? `class="${className}"` : ""} href="${href}">${escapeHtml(label)}</a>`;
}

function textNav(items) {
  return `<nav class="text-nav" aria-label="Primary">${items
    .map(([label, href], index) => `${index ? "<span>|</span>" : ""}${link(label, href)}`)
    .join("")}</nav>`;
}

function socialLinks() {
  return `<div class="social-links">${data.profile.socials
    .map(([label, href], index) => `${index ? "<span>|</span>" : ""}${link(label, href)}`)
    .join("")}</div>`;
}

function layout(content, options = {}) {
  const themeClass = themeClassName(state.activeTheme);
  document.body.className = themeClass;
  document.title = options.title ? `${options.title} - ${data.profile.name}` : data.profile.name;

  return `
    <div class="shell">
      <header class="site-header">
        <div>
          <p class="site-title">${link(data.profile.name, "/")}</p>
          <p class="tagline">${escapeHtml(data.profile.title)}</p>
          ${socialLinks()}
        </div>
        ${textNav(navItems)}
      </header>
      <hr>
      <main>
        ${content}
      </main>
      <footer class="footer">
        <hr>
        <p><strong>Let's connect:</strong> ${data.profile.socials
          .map(([label, href], index) => `${index ? " | " : ""}${link(label, href)}`)
          .join("")}</p>
        <p class="meta">© 2026 ${escapeHtml(data.profile.name)}. Dummy UI. Backend-ready data contract.</p>
      </footer>
    </div>
  `;
}

function themeClassName(theme) {
  return (
    {
      simple: "simple-theme",
      us_builder: "us-builder-theme",
      premium_dark: "premium-dark-theme",
      old_web_classic: "old-web-theme"
    }[theme] || "old-web-theme"
  );
}

function homePage() {
  const settings = data.siteSettings;
  const isOldWeb = state.activeTheme === "old_web_classic";
  const intro = `
    <section>
      ${isOldWeb ? "" : `<h1>${escapeHtml(data.profile.name)}</h1>`}
      <p class="lead">${escapeHtml(settings.headline)}</p>
      <p>${escapeHtml(settings.subheadline)}</p>
      <p>
        ${link(settings.primaryCtaText, settings.primaryCtaUrl, isOldWeb ? "" : "button-link")}
        ${link(settings.secondaryCtaText, settings.secondaryCtaUrl)}
      </p>
    </section>
  `;

  if (state.activeTheme === "us_builder") return layout(usBuilderHome(intro), { title: "Home" });
  if (state.activeTheme === "simple") return layout(simpleHome(intro), { title: "Home" });
  if (state.activeTheme === "premium_dark") return layout(premiumDarkHome(intro), { title: "Home" });

  return layout(`
    ${intro}
    <hr>
    <section>
      <h2>Start Here</h2>
      <p>
        ${link("Browse work", "/work")} |
        ${link("Read writing", "/writing")} |
        ${link("See products", "/products")} |
        ${link("About Nunu", "/about")} |
        ${link("Now", "/now")}
      </p>
    </section>
    <hr>
    <div class="home-grid">
      <div class="home-lists">
        ${featuredWork()}
        ${recentWriting()}
        ${featuredProducts()}
        ${nowBlock()}
      </div>
      ${visualFrame("Ship small. Learn fast.")}
    </div>
  `, { title: "Home" });
}

function simpleHome(intro) {
  return `
    ${intro}
    <hr>
    <div class="home-grid">
      <div>
        ${featuredWork()}
        ${recentWriting()}
        ${featuredProducts()}
      </div>
      <aside>
        ${nowBlock()}
        ${visualFrame("Simple theme, same data.")}
      </aside>
    </div>
  `;
}

function usBuilderHome(intro) {
  return `
    ${intro}
    <section class="notice">
      <strong>Currently building:</strong> ${escapeHtml(data.now.building)} - ${escapeHtml(data.now.body)}
    </section>
    <div class="home-grid">
      <div>
        ${featuredProducts()}
        ${featuredWork()}
      </div>
      <div>
        ${recentWriting()}
        ${visualFrame("Build in public. Sell useful things.")}
      </div>
    </div>
  `;
}

function premiumDarkHome(intro) {
  return `
    ${intro}
    <div class="home-grid">
      <div>
        ${featuredWork()}
        ${featuredProducts()}
      </div>
      <div>
        ${visualFrame("Apps. Systems. Products.")}
        ${recentWriting()}
      </div>
    </div>
  `;
}

function visualFrame(text) {
  return `
    <figure class="media-frame">
      <div class="mock-visual" role="img" aria-label="${escapeHtml(text)}">
        <strong>${escapeHtml(text)}</strong>
      </div>
    </figure>
  `;
}

function featuredWork() {
  return `
    <section>
      <h2>Featured Work</h2>
      <ul>
        ${data.projects
          .filter((project) => project.featured)
          .map((project) => `<li>${link(`${project.title} - ${project.summary}`, `/work/${project.slug}`)}</li>`)
          .join("")}
      </ul>
      ${link("View all work", "/work", "section-link")}
    </section>
  `;
}

function recentWriting() {
  return `
    <section>
      <h2>Recent Writing</h2>
      <ul>
        ${data.posts.map((post) => `<li>${link(post.title, `/writing/${post.slug}`)}</li>`).join("")}
      </ul>
      ${link("View all writing", "/writing", "section-link")}
    </section>
  `;
}

function featuredProducts() {
  return `
    <section>
      <h2>Products</h2>
      <ul>
        ${data.products
          .filter((product) => product.featured)
          .map((product) => `<li>${link(`${product.title} - ${product.summary}`, `/products/${product.slug}`)}</li>`)
          .join("")}
      </ul>
      ${link("View all products", "/products", "section-link")}
    </section>
  `;
}

function nowBlock() {
  return `
    <section>
      <h2>Now</h2>
      <p><strong>Building</strong> ${link(data.now.building, "/now")}, ${escapeHtml(data.now.body)}</p>
      <p>${escapeHtml(data.now.shipping)}</p>
    </section>
  `;
}

function workIndex() {
  return layout(`
    <h1>Work</h1>
    <p>Selected apps, experiments, and product work.</p>
    <p>${["All", "Flutter", "Products", "Experiments", "Client Work"].map((x, i) => `${i ? " | " : ""}${link(x, "/work")}`).join("")}</p>
    <hr>
    <div class="detail-grid">
      <section>
        ${data.projects.map(projectListItem).join("")}
      </section>
      ${visualFrame("Project screenshots live here.")}
    </div>
  `, { title: "Work" });
}

function projectListItem(project) {
  return `
    <article class="item">
      <div class="item-title">${link(`${project.title} - ${project.summary}`, `/work/${project.slug}`)}</div>
      <p>${escapeHtml(project.description)}</p>
      <p class="meta">${escapeHtml(project.year)} · ${project.techStack.map(escapeHtml).join(", ")}</p>
    </article>
  `;
}

function projectDetail(slug) {
  const project = data.projects.find((item) => item.slug === slug);
  if (!project) return notFound();
  return layout(`
    <p class="breadcrumb">${link("Work", "/work")} / ${escapeHtml(project.title)}</p>
    <div class="detail-grid">
      <article>
        <h1>${escapeHtml(project.title)}</h1>
        <p class="tagline">${escapeHtml(project.summary)}</p>
        <p><strong>Role:</strong> ${escapeHtml(project.role)}<br>
        <strong>Stack:</strong> ${project.techStack.map(escapeHtml).join(", ")}<br>
        <strong>Year:</strong> ${escapeHtml(project.year)}<br>
        <strong>Status:</strong> ${escapeHtml(project.status)}</p>
        ${detailSection("Overview", project.description)}
        ${detailSection("Problem", project.problem)}
        ${detailSection("Solution", project.solution)}
        <section class="detail-section">
          <h2>Outcome</h2>
          <ul>${project.result.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>
        </section>
        <section class="detail-section">
          <h2>Links</h2>
          <ul>
            ${project.demoUrl ? `<li>${link("Live Demo", project.demoUrl)}</li>` : ""}
            ${project.githubUrl ? `<li>${link("GitHub", project.githubUrl)}</li>` : ""}
          </ul>
        </section>
      </article>
      ${visualFrame(`${project.title} case study`)}
    </div>
  `, { title: project.title });
}

function detailSection(title, body) {
  return `
    <section class="detail-section">
      <h2>${escapeHtml(title)}</h2>
      <p>${escapeHtml(body)}</p>
    </section>
  `;
}

function writingIndex() {
  return layout(`
    <h1>Writing</h1>
    <p>Builder notes, Flutter lessons, product thinking, and short essays.</p>
    <p>${["All", "Flutter", "Product", "Design", "Build Notes"].map((x, i) => `${i ? " | " : ""}${link(x, "/writing")}`).join("")}</p>
    <hr>
    ${data.posts.map(postListItem).join("")}
  `, { title: "Writing" });
}

function postListItem(post) {
  return `
    <article class="item">
      <div class="item-title">${link(post.title, `/writing/${post.slug}`)}</div>
      <p class="meta">${formatDate(post.publishedAt)} · ${post.readingTime} min read</p>
      <p>${escapeHtml(post.excerpt)}</p>
      <div class="tag-list">${post.tags.map((tag) => `<span class="tag">${escapeHtml(tag)}</span>`).join("")}</div>
    </article>
  `;
}

function postDetail(slug) {
  const post = data.posts.find((item) => item.slug === slug);
  if (!post) return notFound();
  return layout(`
    <p class="breadcrumb">${link("Writing", "/writing")} / ${escapeHtml(post.title)}</p>
    <article>
      <h1>${escapeHtml(post.title)}</h1>
      <p class="meta">${formatDate(post.publishedAt)} · ${post.readingTime} min read</p>
      <p class="lead">${escapeHtml(post.excerpt)}</p>
      <hr>
      <p>${escapeHtml(post.content)}</p>
      <h2>Notes</h2>
      <ul>
        <li>Keep app architecture boring until the product proves it needs more.</li>
        <li>Design for update speed, because content will change more often than the layout.</li>
        <li>Use theme components as presentation only. Data stays shared.</li>
      </ul>
      <hr>
      <p>${link("Back to writing", "/writing")} | ${link("See related work", "/work")}</p>
    </article>
  `, { title: post.title });
}

function productsIndex() {
  return layout(`
    <h1>Products</h1>
    <p>Digital products and experiments. MVP checkout uses external payment links.</p>
    <div class="notice">Phase 1 commerce mode: product detail pages redirect to a manual Midtrans Payment Link through <code>checkout_url</code>.</div>
    <hr>
    ${data.products.map(productListItem).join("")}
  `, { title: "Products" });
}

function productListItem(product) {
  return `
    <article class="item">
      <div class="item-title">${link(product.title, `/products/${product.slug}`)}</div>
      <p>${escapeHtml(product.summary)}</p>
      <p class="meta">${escapeHtml(product.productType)} · ${formatMoney(product)} · ${escapeHtml(product.stockStatus)}</p>
    </article>
  `;
}

function productDetail(slug) {
  const product = data.products.find((item) => item.slug === slug);
  if (!product) return notFound();
  return layout(`
    <p class="breadcrumb">${link("Products", "/products")} / ${escapeHtml(product.title)}</p>
    <div class="detail-grid">
      <article>
        <h1>${escapeHtml(product.title)}</h1>
        <p class="lead">${escapeHtml(product.summary)}</p>
        <p class="price">${formatMoney(product)}</p>
        <p><strong>Type:</strong> ${escapeHtml(product.productType)}<br>
        <strong>Delivery:</strong> ${escapeHtml(product.deliveryType)}<br>
        <strong>Status:</strong> ${escapeHtml(product.stockStatus)}</p>
        <p>${link("Buy Now", product.checkoutUrl, "button-link")}</p>
        <div class="notice">This is still dummy UI. Later, this button can call Phoenix to create an order and Midtrans transaction.</div>
        ${detailSection("Why I Made This", product.description)}
        <section class="detail-section">
          <h2>What Included</h2>
          <ul>${product.included.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>
        </section>
        <section class="detail-section">
          <h2>FAQ</h2>
          ${product.faq.map(([q, a]) => `<h3>${escapeHtml(q)}</h3><p>${escapeHtml(a)}</p>`).join("")}
        </section>
      </article>
      ${visualFrame(`${product.title} preview`)}
    </div>
  `, { title: product.title });
}

function aboutPage() {
  return layout(`
    <div class="detail-grid">
      <section>
        <h1>About</h1>
        <p>${escapeHtml(data.profile.bio)}</p>
        <p>I like useful mobile apps, calm interfaces, readable code, and small products that solve real problems.</p>
      </section>
      ${visualFrame("Handmade but useful.")}
    </div>
    <hr>
    <div class="two-col">
      <section>
        <h2>What I Do</h2>
        <p>I build mobile apps with Flutter, from idea to release.</p>
        <p>I turn fuzzy product ideas into simple flows, prototypes, and shipped software.</p>
        <h2>Tools I Use</h2>
        <ul>
          <li>${link("Flutter", "https://flutter.dev")} for mobile apps</li>
          <li>${link("Elixir", "https://elixir-lang.org")} for scalable backend logic</li>
          <li>${link("Supabase", "https://supabase.com")} for Postgres and storage</li>
          <li>${link("Figma", "https://figma.com")} for product design</li>
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
        ${nowBlock()}
      </section>
    </div>
  `, { title: "About" });
}

function nowPage() {
  return layout(`
    <h1>Now</h1>
    <p class="lead">A small snapshot of what is getting attention right now.</p>
    <hr>
    <h2>Currently Building</h2>
    <p><strong>${escapeHtml(data.now.building)}</strong> - ${escapeHtml(data.now.body)}</p>
    <h2>Learning</h2>
    <p>${escapeHtml(data.now.learning)}</p>
    <h2>Shipping</h2>
    <p>${escapeHtml(data.now.shipping)}</p>
  `, { title: "Now" });
}

function adminPage(section = "dashboard") {
  const adminNav = textNav([
    ["Dashboard", "/admin"],
    ["Projects", "/admin/projects"],
    ["Posts", "/admin/posts"],
    ["Products", "/admin/products"],
    ["Site Settings", "/admin/site-settings"],
    ["Themes", "/admin/themes"]
  ]);

  const content =
    {
      dashboard: adminDashboard,
      projects: () => adminTable("Projects", data.projects, ["title", "status", "year"]),
      posts: () => adminTable("Posts", data.posts, ["title", "publishedAt", "readingTime"]),
      products: () => adminTable("Products", data.products, ["title", "productType", "stockStatus"]),
      "site-settings": adminSettings,
      themes: adminThemes
    }[section]?.() || adminDashboard();

  return layout(`
    <section class="admin-bar">
      <strong>Admin Dummy</strong>
      <p>Forms and lists are frontend-only for now. Later these actions can call Phoenix contexts or API endpoints.</p>
      ${adminNav}
    </section>
    ${content}
  `, { title: "Admin" });
}

function adminDashboard() {
  return `
    <h1>Admin Dashboard</h1>
    <div class="admin-grid">
      <section class="admin-panel">
        <h2>Content Stats</h2>
        <ul>
          <li>${data.projects.length} projects</li>
          <li>${data.posts.length} posts</li>
          <li>${data.products.length} products</li>
          <li>Active theme: <strong>${escapeHtml(state.activeTheme)}</strong></li>
        </ul>
      </section>
      <section class="admin-panel">
        <h2>Quick Actions</h2>
        <p>${link("Add project", "/admin/projects", "button-link")}</p>
        <p>${link("Write post", "/admin/posts", "button-link")}</p>
        <p>${link("Add product", "/admin/products", "button-link")}</p>
        <p>${link("Switch theme", "/admin/themes", "button-link")}</p>
      </section>
    </div>
  `;
}

function adminTable(title, rows, columns) {
  return `
    <section class="admin-panel">
      <h1>${escapeHtml(title)}</h1>
      <table class="admin-table">
        <thead>
          <tr>${columns.map((column) => `<th>${escapeHtml(labelize(column))}</th>`).join("")}<th>Actions</th></tr>
        </thead>
        <tbody>
          ${rows
            .map(
              (row) => `
                <tr>
                  ${columns.map((column) => `<td>${escapeHtml(row[column] ?? "")}</td>`).join("")}
                  <td>${link("Edit", "#")} | ${link("Preview", previewUrl(title, row))}</td>
                </tr>
              `
            )
            .join("")}
        </tbody>
      </table>
      <h2>Dummy Form</h2>
      ${dummyForm(title)}
    </section>
  `;
}

function adminSettings() {
  return `
    <section class="admin-panel">
      <h1>Site Settings</h1>
      <form class="form-grid" data-dummy-form>
        <label>Headline <input value="${escapeHtml(data.siteSettings.headline)}"></label>
        <label>Subheadline <textarea>${escapeHtml(data.siteSettings.subheadline)}</textarea></label>
        <label>Primary CTA Text <input value="${escapeHtml(data.siteSettings.primaryCtaText)}"></label>
        <label>Primary CTA URL <input value="${escapeHtml(data.siteSettings.primaryCtaUrl)}"></label>
        <button type="submit">Save Dummy Settings</button>
      </form>
    </section>
  `;
}

function adminThemes() {
  return `
    <section class="admin-panel">
      <h1>Theme Settings</h1>
      <p>Switching this value updates <code>site_settings.active_theme</code> in the dummy frontend store.</p>
      <form class="form-grid" id="theme-form">
        <label>Active Theme
          <select name="theme">
            ${data.themes
              .map((theme) => `<option value="${theme.key}" ${theme.key === state.activeTheme ? "selected" : ""}>${theme.name}</option>`)
              .join("")}
          </select>
        </label>
        <button type="submit">Save Theme</button>
      </form>
      <div class="two-col">
        ${data.themes
          .map(
            (theme) => `
              <article>
                <h2>${escapeHtml(theme.name)}</h2>
                <p>${escapeHtml(theme.description)}</p>
                <div class="theme-preview ${escapeHtml(theme.key)}">
                  <strong>${escapeHtml(data.profile.name)}</strong>
                  <p>${escapeHtml(data.siteSettings.headline)}</p>
                  <p>Work | Writing | Products | About</p>
                </div>
              </article>
            `
          )
          .join("")}
      </div>
    </section>
  `;
}

function dummyForm(title) {
  return `
    <form class="form-grid" data-dummy-form>
      <label>Title <input placeholder="${escapeHtml(`New ${title.slice(0, -1)}`)}"></label>
      <label>Slug <input placeholder="auto-generated-slug"></label>
      <label>Summary <textarea placeholder="Short summary for public pages"></textarea></label>
      <label>Status
        <select>
          <option>draft</option>
          <option>published</option>
          <option>active</option>
          <option>archived</option>
        </select>
      </label>
      <button type="submit">Save Dummy ${escapeHtml(title.slice(0, -1))}</button>
    </form>
  `;
}

function notFound() {
  return layout(`
    <h1>Page Not Found</h1>
    <p>The requested dummy route does not exist yet.</p>
    <p>${link("Back home", "/")}</p>
  `, { title: "Not Found" });
}

function formatDate(value) {
  return new Intl.DateTimeFormat("en", { year: "numeric", month: "long", day: "numeric" }).format(new Date(value));
}

function formatMoney(product) {
  return new Intl.NumberFormat("en", { style: "currency", currency: product.currency }).format(product.price);
}

function labelize(value) {
  return value.replace(/([A-Z])/g, " $1").replace(/^./, (char) => char.toUpperCase());
}

function previewUrl(title, row) {
  if (title === "Projects") return `/work/${row.slug}`;
  if (title === "Posts") return `/writing/${row.slug}`;
  if (title === "Products") return `/products/${row.slug}`;
  return "/";
}

function route(pathname = window.location.pathname) {
  const parts = pathname.split("/").filter(Boolean);
  if (pathname === "/") return homePage();
  if (pathname === "/work") return workIndex();
  if (parts[0] === "work" && parts[1]) return projectDetail(parts[1]);
  if (pathname === "/writing") return writingIndex();
  if (parts[0] === "writing" && parts[1]) return postDetail(parts[1]);
  if (pathname === "/products") return productsIndex();
  if (parts[0] === "products" && parts[1]) return productDetail(parts[1]);
  if (pathname === "/about") return aboutPage();
  if (pathname === "/now") return nowPage();
  if (pathname === "/admin") return adminPage("dashboard");
  if (parts[0] === "admin" && parts[1]) return adminPage(parts[1]);
  return notFound();
}

function render(pathname = window.location.pathname) {
  app.innerHTML = route(pathname);
  window.scrollTo({ top: 0, behavior: "auto" });
}

document.addEventListener("click", (event) => {
  const anchor = event.target.closest("a");
  if (!anchor) return;
  const url = new URL(anchor.href);
  if (url.origin !== window.location.origin) return;
  event.preventDefault();
  window.history.pushState({}, "", url.pathname);
  render(url.pathname);
});

document.addEventListener("submit", (event) => {
  const themeForm = event.target.closest("#theme-form");
  const dummyForm = event.target.closest("[data-dummy-form]");
  if (!themeForm && !dummyForm) return;
  event.preventDefault();
  if (themeForm) {
    const theme = new FormData(themeForm).get("theme");
    state.activeTheme = theme;
    localStorage.setItem("active_theme", theme);
    window.history.pushState({}, "", "/");
    render("/");
    return;
  }
  alert("Dummy save only. Later this will call the backend.");
});

window.addEventListener("popstate", () => render());

render();
