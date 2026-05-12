defmodule PersonalBrandWeb.SeoController do
  use PersonalBrandWeb, :controller

  alias PersonalBrand.Content

  def sitemap(conn, _params) do
    projects = Content.list_published_projects()
    posts = Content.list_posts()
    products = Content.list_products()

    urls = [
      %{loc: "/", priority: "1.0", changefreq: "weekly"},
      %{loc: "/work", priority: "0.9", changefreq: "weekly"},
      %{loc: "/writing", priority: "0.8", changefreq: "weekly"},
      %{loc: "/products", priority: "0.7", changefreq: "weekly"},
      %{loc: "/about", priority: "0.6", changefreq: "monthly"},
      %{loc: "/now", priority: "0.5", changefreq: "monthly"},
      %{loc: "/contact", priority: "0.5", changefreq: "monthly"}
    ]

    project_urls =
      Enum.map(projects, fn p ->
        %{loc: "/work/#{p.slug}", priority: "0.8", changefreq: "monthly"}
      end)

    post_urls =
      Enum.map(posts, fn p ->
        %{loc: "/writing/#{p.slug}", priority: "0.7", changefreq: "monthly"}
      end)

    product_urls =
      Enum.map(products, fn p ->
        %{loc: "/products/#{p.slug}", priority: "0.6", changefreq: "monthly"}
      end)

    all_urls = urls ++ project_urls ++ post_urls ++ product_urls

    xml = build_sitemap(all_urls)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml)
  end

  def rss(conn, _params) do
    posts = Content.list_posts()
    settings = Content.get_site_settings()
    site_name = (settings && settings.site_name) || "Nunu Nugraha"

    items =
      Enum.map(posts, fn post ->
        %{
          title: post.title,
          link: "https://nunutech40.dev/writing/#{post.slug}",
          description: post.excerpt || "",
          pub_date: post.published_at && format_rss_date(post.published_at),
          guid: post.slug
        }
      end)

    xml = build_rss(site_name, "https://nunutech40.dev/writing", items)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> send_resp(200, xml)
  end

  defp build_sitemap(urls) do
    urlset =
      Enum.map(urls, fn u ->
        """
          <url>
            <loc>https://nunutech40.dev#{u.loc}</loc>
            <priority>#{u.priority}</priority>
            <changefreq>#{u.changefreq}</changefreq>
          </url>
        """
      end)
      |> Enum.join("\n")

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{urlset}
    </urlset>
    """
  end

  defp build_rss(site_name, link, items) do
    item_xml =
      Enum.map(items, fn item ->
        """
          <item>
            <title>#{escape_xml(item.title)}</title>
            <link>#{escape_xml(item.link)}</link>
            <description>#{escape_xml(item.description)}</description>
            <guid>#{escape_xml(item.guid)}</guid>
            #{if item.pub_date, do: "<pubDate>#{item.pub_date}</pubDate>", else: ""}
          </item>
        """
      end)
      |> Enum.join("\n")

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>#{escape_xml(site_name)}</title>
        <link>#{escape_xml(link)}</link>
        <description>Writing and articles by #{escape_xml(site_name)}</description>
        <language>en</language>
        <atom:link href="https://nunutech40.dev/writing/feed.xml" rel="self" type="application/rss+xml"/>
    #{item_xml}
      </channel>
    </rss>
    """
  end

  defp format_rss_date(%{year: y, month: m, day: d}) do
    # RFC 2822 format
    month_names = ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    month_str = Enum.at(month_names, m - 1)
    "#{d} #{month_str} #{y} 00:00:00 UTC"
  end

  defp format_rss_date(_), do: nil

  defp escape_xml(value) when is_binary(value) do
    value
    |> String.replace("&", "&")
    |> String.replace("<", "<")
    |> String.replace(">", ">")
    |> String.replace(~S("), ~S("))
    |> String.replace(~S('), ~S('))
  end

  defp escape_xml(nil), do: ""
end
