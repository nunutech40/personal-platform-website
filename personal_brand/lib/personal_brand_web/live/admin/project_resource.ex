defmodule PersonalBrandWeb.Admin.ProjectResource do
  use PersonalBrandWeb, :html

  alias PersonalBrand.Content
  alias PersonalBrand.Content.Project
  alias PersonalBrandWeb.Admin.ResourceUI

  use Backpex.LiveResource,
    adapter: Backpex.Adapters.Ecto,
    adapter_config: [
      schema: Project,
      repo: PersonalBrand.Repo,
      create_changeset: &__MODULE__.create_changeset/3,
      update_changeset: &Project.changeset/3
    ]

  @impl true
  def singular_name, do: "Project"

  @impl true
  def plural_name, do: "Project Portfolio"

  @impl true
  def panels do
    [
      identity: "Info Dasar",
      classification: "Klasifikasi & Peran",
      recruiter_pitch: "Pitch untuk Recruiter",
      case_study: "Case Study Detail",
      evidence: "Bukti & Hasil",
      media_links: "Media & Link"
    ]
  end

  @impl true
  def item_actions(default_actions) do
    default_actions
    |> Keyword.put(:show, %{
      module: Backpex.ItemActions.Show,
      only: [:show]
    })
    |> Keyword.put(:edit, %{
      module: PersonalBrandWeb.Admin.ItemActions.EditProject,
      only: [:show]
    })
    |> Keyword.put(:view_public, %{
      module: PersonalBrandWeb.Admin.ItemActions.ViewPublicProject,
      only: [:show]
    })
    |> Keyword.put(:delete, %{
      module: Backpex.ItemActions.Delete,
      only: [:show]
    })
  end

  @impl true
  def layout(_assigns) do
    {PersonalBrandWeb.Layouts, :admin}
  end

  @impl true
  def fields do
    [
      admin_actions: %{
        module: Backpex.Fields.Text,
        label: "Aksi",
        only: [:index],
        render: &render_admin_actions/1,
        index_column_class: "min-w-64"
      },
      title: %{
        module: Backpex.Fields.Text,
        label: "Judul Project",
        placeholder: "Contoh: Personal Platform Website",
        help_text: "Nama project yang akan tampil di halaman Work dan card portfolio.",
        searchable: true,
        panel: :identity
      },
      slug: %{
        module: Backpex.Fields.Text,
        label: "URL Project (slug)",
        placeholder: "personal-platform-website",
        help_text:
          "Alamat URL publik project, muncul di /work/<slug>. Kosongkan saja saat membuat project baru, sistem akan buat otomatis dari judul. Hati-hati mengubah slug project yang sudah terbit karena link lama bisa patah.",
        panel: :identity
      },
      summary: %{
        module: Backpex.Fields.Textarea,
        label: "Ringkasan Singkat",
        rows: 3,
        placeholder:
          "Satu-dua kalimat yang menjelaskan project ini. Contoh: Platform personal berbasis Phoenix LiveView untuk portfolio, writing, dan CMS admin.",
        help_text:
          "Dipakai sebagai one-liner di card /work. Fokus ke impact atau konteks singkat, bukan deskripsi teknis panjang.",
        index_column_class: "min-w-80",
        panel: :recruiter_pitch
      },
      description: %{
        module: Backpex.Fields.Textarea,
        label: "Deskripsi Lengkap",
        rows: 8,
        placeholder:
          "Jelaskan konteks project, siapa user-nya, scope pekerjaan, dan kenapa project ini penting untuk portfolio recruiter.",
        help_text: "Bagian overview di halaman detail project publik.",
        except: [:index],
        panel: :case_study
      },
      problem: %{
        module: Backpex.Fields.Textarea,
        label: "Problem yang Diselesaikan",
        rows: 5,
        placeholder:
          "Contoh: Portfolio sebelumnya sulit di-update, data tersebar, dan recruiter tidak cepat melihat role, impact, serta technical depth.",
        help_text: "Masalah user atau bisnis yang project ini selesaikan.",
        except: [:index],
        panel: :case_study
      },
      solution: %{
        module: Backpex.Fields.Textarea,
        label: "Solusi / Pendekatan Teknis",
        rows: 5,
        placeholder:
          "Contoh: Membangun Phoenix LiveView CMS dengan PostgreSQL, Backpex admin, auto slug, taxonomy project, dan halaman case study publik.",
        help_text:
          "Cara kamu menyelesaikan problem di atas. Tunjukkan ownership dan decision teknis.",
        except: [:index],
        panel: :case_study
      },
      architecture_notes: %{
        module: Backpex.Fields.Textarea,
        label: "Catatan Arsitektur",
        rows: 6,
        placeholder:
          "Contoh: Content context mengatur query published/draft. Public route membaca project by slug. Admin memakai Backpex resource dan Ecto changeset.",
        help_text:
          "Catatan arsitektur, boundary antar modul, atau pattern penting. Buat menunjukkan seniority teknis.",
        except: [:index],
        panel: :case_study
      },
      tradeoffs: %{
        module: Backpex.Fields.Textarea,
        label: "Trade-off / Keputusan yang Diambil",
        rows: 5,
        placeholder:
          "Contoh: Taxonomy pakai enum-array dulu agar cepat ship; taxonomy table dan gallery media ditunda sampai admin workflow makin kompleks.",
        help_text: "Keputusan teknis dengan alasannya, termasuk yang sengaja tidak dikerjakan.",
        except: [:index],
        panel: :case_study
      },
      result: %{
        module: Backpex.Fields.Textarea,
        label: "Hasil Project",
        rows: 6,
        placeholder:
          "Recruiter bisa scan project lebih cepat\nAdmin bisa create/edit project tanpa akses database\nPublic case study bisa dibuka lewat /work/<slug>",
        help_text:
          "Satu hasil per baris. Tekan Enter untuk baris baru. Fokus ke outcome yang bisa diverifikasi.",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      role: %{
        module: Backpex.Fields.Text,
        label: "Peran Kamu di Project",
        placeholder: "Contoh: Full-stack Engineer / Mobile Engineering Lead",
        help_text:
          "Jabatan atau peran kamu di project ini. Tampil di card /work dan detail project.",
        render_form: &render_suggested_text_input/1,
        searchable: true,
        panel: :classification
      },
      ownership: %{
        module: Backpex.Fields.Text,
        label: "Ruang Lingkup Tanggung Jawab",
        placeholder:
          "Contoh: Solo builder end-to-end: schema, admin CMS, public UI, tests, deployment workflow",
        help_text:
          "Scope pekerjaan kamu di project ini. Contoh: Solo builder, Feature owner, atau Technical lead.",
        render_form: &render_suggested_text_input/1,
        except: [:index],
        panel: :classification
      },
      team_size: %{
        module: Backpex.Fields.Text,
        label: "Ukuran Tim",
        placeholder: "Contoh: Solo / 2 iOS engineers / Cross-functional team of 6",
        help_text: "Jumlah dan komposisi tim saat mengerjakan project ini.",
        render_form: &render_suggested_text_input/1,
        except: [:index],
        panel: :classification
      },
      project_type: %{
        module: Backpex.Fields.Select,
        label: "Tipe Project",
        help_text:
          "Kategori project. Pilih Professional Work untuk project kantor, Personal Project untuk karya pribadi, Client Work untuk project klien.",
        options: select_options(Project.project_types()),
        render: &render_label/1,
        panel: :classification
      },
      platforms: %{
        module: Backpex.Fields.MultiSelect,
        label: "Platform",
        options: fn _assigns -> taxonomy_options(:platforms, Project.platforms()) end,
        prompt: "Pilih platform yang dipakai",
        help_text:
          "Platform yang kamu kerjakan di project ini (iOS, Android, Web, Backend, dll). Recruiter pakai ini untuk filter project di halaman Work. Bisa pilih lebih dari satu.",
        render: &render_badges/1,
        render_form: &render_taxonomy_checkbox_group/1,
        index_column_class: "w-48 max-w-48",
        panel: :classification
      },
      disciplines: %{
        module: Backpex.Fields.MultiSelect,
        label: "Keahlian / Discipline",
        options: fn _assigns -> taxonomy_options(:disciplines, Project.disciplines()) end,
        prompt: "Pilih keahlian yang ditunjukkan",
        help_text:
          "Keahlian atau peran engineering yang kamu tunjukkan di project ini (iOS Development, Backend Engineering, dll). Muncul sebagai filter di halaman Work. Bisa pilih lebih dari satu.",
        render: &render_badges/1,
        render_form: &render_taxonomy_checkbox_group/1,
        index_column_class: "w-64 max-w-64",
        panel: :classification
      },
      tech_stack: %{
        module: Backpex.Fields.Textarea,
        label: "Tech Stack",
        rows: 4,
        placeholder: "Elixir\nPhoenix LiveView\nPostgreSQL\nBackpex",
        help_text:
          "Teknologi yang dipakai. Satu teknologi per baris, tekan Enter untuk baris baru.",
        render: &render_stack_preview/1,
        render_form: &render_textarea/1,
        index_column_class: "w-80 max-w-80",
        panel: :evidence
      },
      year: %{
        module: Backpex.Fields.Text,
        label: "Tahun",
        placeholder: "2026",
        help_text: "Tahun project dikerjakan. Boleh rentang tahun, contoh: 2021-2024.",
        panel: :identity
      },
      duration: %{
        module: Backpex.Fields.Text,
        label: "Periode Pengerjaan",
        placeholder: "Contoh: Jan 2026 - May 2026 / 3 months",
        help_text: "Durasi atau periode pengerjaan yang lebih spesifik dari tahun. Opsional.",
        panel: :identity
      },
      sort_date: %{
        module: Backpex.Fields.Date,
        label: "Tanggal Sortir",
        help_text:
          "Tanggal untuk urutan tahun-bulan di Work. Isi awal project atau tanggal publish portfolio. Tidak tampil ke publik.",
        except: [:index],
        panel: :identity
      },
      company: %{
        module: Backpex.Fields.Text,
        label: "Perusahaan",
        placeholder: "Contoh: Personal Project / Komerce / Prodia",
        help_text:
          "Perusahaan tempat project ini dikerjakan. Isi Personal Project jika karya pribadi.",
        render_form: &render_suggested_text_input/1,
        except: [:index],
        panel: :classification
      },
      client: %{
        module: Backpex.Fields.Text,
        label: "Klien / Pengguna",
        placeholder: "Contoh: Internal portfolio / Confidential client / Public users",
        help_text:
          "Siapa pengguna project ini. Untuk project proprietary, boleh pakai label umum seperti Confidential client.",
        render_form: &render_suggested_text_input/1,
        except: [:index],
        panel: :classification
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status Publikasi",
        help_text:
          "Draft = belum tampil di web. Published = tampil di /work. Archived = disembunyikan tapi data tetap tersimpan.",
        options: select_options(Project.statuses()),
        render: &render_status_badge/1,
        panel: :identity
      },
      featured: %{
        module: Backpex.Fields.Boolean,
        label: "Tampilkan di Urutan Teratas",
        help_text:
          "Aktifkan untuk project yang paling penting untuk recruiter. Project yang di-featured muncul paling atas di halaman Work dan homepage.",
        render: &render_featured_badge/1,
        render_form: &render_featured_toggle/1,
        panel: :identity
      },
      sort_order: %{
        module: Backpex.Fields.Number,
        label: "Urutan Tampil",
        placeholder: "0",
        index_column_class: "w-24",
        help_text:
          "Angka untuk mengatur urutan project di halaman Work. Angka lebih kecil tampil lebih dulu. Contoh: project paling penting isi 0, berikutnya 10, lalu 20. Kosongkan atau isi 0 kalau tidak yakin.",
        panel: :identity
      },
      impact_summary: %{
        module: Backpex.Fields.Textarea,
        label: "Ringkasan Impact",
        rows: 3,
        placeholder:
          "Contoh: Mengubah portfolio dari halaman statis menjadi CMS yang bisa di-update cepat untuk kebutuhan melamar kerja.",
        help_text:
          "Dampak/impact project dalam 1-2 kalimat. Ini tampil di card /work untuk menarik perhatian recruiter.",
        except: [:index],
        panel: :recruiter_pitch
      },
      technical_highlights: %{
        module: Backpex.Fields.Textarea,
        label: "Highlight Teknis",
        rows: 6,
        placeholder:
          "Auto-generated unique slug\nAdmin CRUD dengan Backpex\nPublic filtering by platform/discipline\nTests untuk create/edit/detail visibility",
        help_text:
          "Bullet point hal teknis yang menunjukkan seniority. Satu item per baris, tekan Enter untuk baris baru.",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      metrics: %{
        module: Backpex.Fields.Textarea,
        label: "Metrik / Angka Hasil",
        rows: 5,
        placeholder:
          "169 automated tests passing\n5 recruiter-ready projects published\nAdmin create/edit workflow covered by tests",
        help_text:
          "Angka atau metrik yang bisa dipercaya. Kalau project proprietary, boleh pakai metric kualitatif. Satu item per baris.",
        render: &render_list/1,
        render_form: &render_textarea/1,
        except: [:index],
        panel: :evidence
      },
      case_study_visibility: %{
        module: Backpex.Fields.Select,
        label: "Tingkat Detail Case Study",
        help_text:
          "Public = boleh ceritakan detail teknis. Limited = sebagian detail disimpan. Private Summary = hanya ringkasan untuk project yang sangat rahasia.",
        options: select_options(Project.case_study_visibilities()),
        render: &render_label/1,
        panel: :case_study
      },
      demo_url: %{
        module: Backpex.Fields.Text,
        label: "Link Demo / Live Site",
        placeholder: "https://nununugraha.dev/work/personal-platform-website",
        help_text:
          "URL demo/live site interaktif. Harus dimulai dengan http:// atau https://. Opsional.",
        panel: :media_links
      },
      demo_video_url: %{
        module: Backpex.Fields.Text,
        label: "Link Video Demo",
        placeholder: "https://raw.githubusercontent.com/nunutech40/repo/main/docs/demo/demo.mp4",
        help_text:
          "URL video demo publik. Bisa raw GitHub release/raw file, Google Drive, YouTube, atau link publik lain. Direct .mp4/.webm akan tampil sebagai video di detail project.",
        panel: :media_links
      },
      github_url: %{
        module: Backpex.Fields.Text,
        label: "Link GitHub",
        placeholder: "https://github.com/nunutech40/personal-platform-website",
        help_text: "URL repository GitHub. Untuk project open-source atau demo publik. Opsional.",
        panel: :media_links
      },
      app_store_url: %{
        module: Backpex.Fields.Text,
        label: "Link App Store",
        placeholder: "https://apps.apple.com/app/example/id123456789",
        help_text: "URL App Store untuk project iOS/mobile yang sudah rilis. Opsional.",
        panel: :media_links
      },
      cover_image: %{
        module: Backpex.Fields.BelongsTo,
        label: "Gambar Cover",
        display_field: :filename,
        display_field_form: :filename,
        live_resource: PersonalBrandWeb.Admin.MediaResource,
        prompt: "Pilih gambar cover",
        help_text:
          "Gambar utama project untuk card /work dan hero detail page. Upload dulu di Admin > Media, lalu pilih di sini.",
        except: [:index],
        panel: :media_links
      },
      certificate_media: %{
        module: Backpex.Fields.BelongsTo,
        label: "Sertifikat PDF",
        display_field: :filename,
        display_field_form: :filename,
        live_resource: PersonalBrandWeb.Admin.MediaResource,
        prompt: "Pilih sertifikat PDF",
        help_text:
          "Upload PDF sertifikat di Admin > Media dengan content type application/pdf, lalu pilih di sini. Tampil sebagai download link di detail work.",
        except: [:index],
        panel: :media_links
      },
      updated_at: %{
        module: Backpex.Fields.DateTime,
        label: "Terakhir Diubah",
        except: [:new, :edit],
        orderable: true
      }
    ]
  end

  @impl true
  def render_resource_slot(assigns, :index, :main) do
    ~H"""
    <ResourceUI.index_main {assigns} />
    """
  end

  def render_resource_slot(
        %{item: %{status: "published", slug: slug}} = assigns,
        :edit,
        :before_main
      ) do
    assigns = assign(assigns, :public_path, "/work/#{slug}")

    ~H"""
    <div class="alert alert-warning mb-4">
      <div>
        <p class="font-semibold">
          Project ini sudah terbit di: <a href={@public_path}>{@public_path}</a>
        </p>
        <p class="text-sm">
          Mengubah URL Project (slug) akan mengubah link publik di atas, jadi link lama bisa patah. Ubah hanya kalau memang perlu.
        </p>
      </div>
    </div>
    """
  end

  def render_resource_slot(assigns, :new, :before_main) do
    ~H"""
    <div class="alert alert-info mb-4">
      <p>
        Isi Judul Project dulu. URL Project (slug) boleh dikosongkan, sistem akan buat otomatis dari judul.
      </p>
    </div>
    """
  end

  def create_changeset(project, attrs, metadata) do
    project
    |> Project.changeset(Content.put_unique_project_slug(attrs), metadata)
  end

  defp select_options(values), do: Enum.map(values, &{Project.label_for(&1), &1})

  defp taxonomy_options(field, allowed_values) do
    existing_values =
      field
      |> Content.list_project_array_values()
      |> Enum.filter(&(&1 in allowed_values))

    (existing_values ++ allowed_values)
    |> Enum.uniq()
    |> Enum.map(&{Project.label_for(&1), &1})
  end

  defp suggested_project_values(field, fallback_values) do
    field
    |> Content.list_project_field_values()
    |> Kernel.++(fallback_values)
    |> Enum.reject(&(is_nil(&1) or String.trim(&1) == ""))
    |> Enum.uniq()
  end

  defp render_label(assigns) do
    assigns = assign(assigns, :display_value, display_label(assigns[:value]))

    ~H"""
    <span>{@display_value}</span>
    """
  end

  defp render_badges(assigns) do
    assigns = assign_limited_values(assigns, assigns[:value], 3, &display_label/1)

    ~H"""
    <div class="admin-index-chips" title={@full_value}>
      <span :for={value <- @visible_values} class="badge badge-outline badge-sm">
        {value}
      </span>
      <span :if={@remaining_count > 0} class="badge badge-ghost badge-sm">
        +{@remaining_count}
      </span>
      <span :if={@visible_values == []}>-</span>
    </div>
    """
  end

  defp render_admin_actions(assigns) do
    assigns = assign(assigns, :public_path, "/work/#{assigns.item.slug}")

    ~H"""
    <div class="flex min-w-64 items-center gap-2">
      <.link
        navigate={"/admin/projects/#{@primary_key}/edit"}
        class="rounded border border-blue-200 px-2 py-1 text-xs font-semibold text-blue-700 transition hover:border-blue-300 hover:bg-blue-50"
      >
        Ubah
      </.link>
      <.link
        navigate={@public_path}
        class="rounded border border-slate-200 px-2 py-1 text-xs font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50"
      >
        Lihat Publik
      </.link>
      <button
        type="button"
        phx-click="item-action"
        phx-value-action-key="delete"
        phx-value-item-id={@primary_key}
        data-confirm={"Yakin hapus project \"#{@item.title}\"? Data yang dihapus tidak bisa dikembalikan."}
        class="rounded border border-red-200 px-2 py-1 text-xs font-semibold text-red-700 transition hover:border-red-300 hover:bg-red-50"
      >
        Hapus
      </button>
    </div>
    """
  end

  defp render_status_badge(assigns) do
    assigns = assign(assigns, :display_value, display_label(assigns[:value]))

    status_class =
      case assigns[:value] do
        "published" -> "badge badge-success badge-sm"
        "draft" -> "badge badge-warning badge-sm"
        "archived" -> "badge badge-ghost badge-sm"
        _ -> "badge badge-outline badge-sm"
      end

    assigns = assign(assigns, :status_class, status_class)

    ~H"""
    <span class={@status_class}>{@display_value}</span>
    """
  end

  defp render_featured_badge(assigns) do
    ~H"""
    <span>
      <span :if={@value} class="badge badge-primary badge-sm">Unggulan</span>
      <span :if={!@value} class="text-slate-400">-</span>
    </span>
    """
  end

  defp render_featured_toggle(assigns) do
    checked? = Phoenix.HTML.Form.normalize_value("checkbox", assigns.form[assigns.name].value)

    assigns = assign(assigns, :checked?, checked?)

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <label for={@form[@name].id} class="text-content mb-2 block break-words text-sm font-medium">
        {@field_options[:label]}
      </label>

      <div class="inline-flex items-center rounded-md border border-slate-300 bg-slate-100 p-1">
        <input type="hidden" name={@form[@name].name} value="false" tabindex="-1" aria-hidden="true" />
        <label class={[
          "cursor-pointer rounded px-3 py-1.5 text-sm font-semibold transition",
          !@checked? && "bg-white text-slate-900 shadow-sm",
          @checked? && "text-slate-500 hover:text-slate-800"
        ]}>
          <input
            id={@form[@name].id}
            type="radio"
            name={@form[@name].name}
            value="false"
            checked={!@checked?}
            class="sr-only"
          /> Biasa
        </label>
        <label class={[
          "cursor-pointer rounded px-3 py-1.5 text-sm font-semibold transition",
          @checked? && "bg-blue-600 text-white shadow-sm",
          !@checked? && "text-slate-500 hover:text-slate-800"
        ]}>
          <input
            type="radio"
            name={@form[@name].name}
            value="true"
            checked={@checked?}
            class="sr-only"
          /> Unggulan
        </label>
      </div>

      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp render_suggested_text_input(assigns) do
    assigns =
      assigns
      |> assign(:suggestions, suggested_values_for(assigns.name))
      |> assign(:list_id, "#{assigns.form[assigns.name].id}_suggestions")

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <label for={@form[@name].id} class="text-content mb-2 block break-words text-sm font-medium">
        {@field_options[:label]}
      </label>
      <input
        id={@form[@name].id}
        name={@form[@name].name}
        value={Phoenix.HTML.Form.normalize_value("text", @form[@name].value)}
        placeholder={@field_options[:placeholder]}
        list={if @suggestions == [], do: nil, else: @list_id}
        class="input w-full"
      />
      <datalist :if={@suggestions != []} id={@list_id}>
        <option :for={value <- @suggestions} value={value}></option>
      </datalist>
      <p :if={@suggestions != []} class="mt-2 text-sm opacity-70">
        Ketik sendiri atau pilih dari saran di atas (berdasarkan project yang sudah ada).
      </p>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp suggested_values_for(:role) do
    suggested_project_values(:role, [
      "Software Engineer",
      "Frontend Engineer",
      "Backend Engineer",
      "Full-stack Engineer",
      "Mobile Engineer",
      "iOS Developer",
      "Flutter Developer"
    ])
  end

  defp suggested_values_for(:ownership) do
    suggested_project_values(:ownership, [
      "Individual contributor",
      "Feature owner",
      "Solo builder",
      "Technical lead",
      "End-to-end implementation",
      "Architecture and implementation"
    ])
  end

  defp suggested_values_for(:team_size) do
    suggested_project_values(:team_size, [
      "Solo",
      "2 engineers",
      "Small engineering team",
      "Cross-functional team"
    ])
  end

  defp suggested_values_for(:company) do
    suggested_project_values(:company, [
      "Personal Project",
      "Freelance",
      "Client Project",
      "Internal Product"
    ])
  end

  defp suggested_values_for(:client) do
    suggested_project_values(:client, [
      "Internal users",
      "Public users",
      "Client team",
      "Recruiters"
    ])
  end

  defp suggested_values_for(_field), do: []

  defp render_taxonomy_checkbox_group(assigns) do
    selected_values =
      assigns.form
      |> Phoenix.HTML.Form.input_value(assigns.name)
      |> list_value()

    assigns =
      assigns
      |> assign(:options, taxonomy_form_options(assigns))
      |> assign(:selected_values, selected_values)

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <fieldset>
        <legend class="text-content mb-2 block break-words text-sm font-medium">
          {@field_options[:label]}
        </legend>
        <p :if={@field_options[:prompt]} class="mb-3 text-sm text-slate-500">
          {@field_options[:prompt]}
        </p>

        <input type="hidden" name={@form[@name].name} value="" tabindex="-1" aria-hidden="true" />

        <div class="grid gap-2 sm:grid-cols-2 xl:grid-cols-3">
          <label
            :for={{label, value} <- @options}
            class={[
              "flex cursor-pointer items-center gap-3 rounded-md border px-3 py-2 text-sm font-medium transition",
              value in @selected_values &&
                "border-blue-500 bg-blue-50 text-blue-950 ring-1 ring-blue-500",
              value not in @selected_values &&
                "border-slate-200 bg-white text-slate-800 hover:border-slate-300 hover:bg-slate-50"
            ]}
          >
            <input
              type="checkbox"
              name={@form[@name].name <> "[]"}
              value={value}
              checked={value in @selected_values}
              class="size-4 flex-none accent-blue-600"
              style="width: 1rem; height: 1rem;"
            />
            <span>{label}</span>
          </label>
        </div>

        <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
          {@field_options[:help_text]}
        </p>
      </fieldset>
    </div>
    """
  end

  defp taxonomy_form_options(assigns) do
    case assigns.field_options[:options] do
      options when is_function(options, 1) -> options.(assigns)
      options when is_list(options) -> options
      _options -> []
    end
  end

  defp render_list(assigns) do
    assigns = assign(assigns, :display_value, display_value(assigns[:value]))

    ~H"""
    <span>{@display_value}</span>
    """
  end

  defp render_stack_preview(assigns) do
    assigns = assign_limited_values(assigns, assigns[:value], 5, & &1)

    ~H"""
    <div class="admin-index-chips admin-index-chips-tech" title={@full_value}>
      <span :for={value <- @visible_values} class="badge badge-outline badge-sm">
        {value}
      </span>
      <span :if={@remaining_count > 0} class="badge badge-ghost badge-sm">
        +{@remaining_count}
      </span>
      <span :if={@visible_values == []}>-</span>
    </div>
    """
  end

  defp render_textarea(assigns) do
    assigns =
      assign(assigns, :textarea_value, textarea_value(assigns[:value]))

    ~H"""
    <div class="px-6 py-4 sm:py-3">
      <label for={@form[@name].id} class="text-content mb-2 block break-words text-sm font-medium">
        {@field_options[:label]}
      </label>
      <textarea
        id={@form[@name].id}
        name={@form[@name].name}
        rows={@field_options[:rows] || 4}
        placeholder={@field_options[:placeholder]}
        class="textarea w-full"
      >{@textarea_value}</textarea>
      <p :if={@field_options[:help_text]} class="mt-2 text-sm opacity-70">
        {@field_options[:help_text]}
      </p>
    </div>
    """
  end

  defp textarea_value(value) when is_list(value), do: Enum.join(value, "\n")
  defp textarea_value(value) when is_binary(value), do: value
  defp textarea_value(_value), do: ""

  defp list_value(value) when is_list(value), do: value
  defp list_value(value) when is_binary(value) and value != "", do: [value]
  defp list_value(_value), do: []

  defp assign_limited_values(assigns, value, limit, label_fun) do
    values =
      value
      |> list_value()
      |> Enum.reject(&(is_nil(&1) or &1 == ""))

    labels = Enum.map(values, label_fun)

    assigns
    |> assign(:visible_values, Enum.take(labels, limit))
    |> assign(:remaining_count, max(length(labels) - limit, 0))
    |> assign(:full_value, Enum.join(labels, ", "))
  end

  defp display_label(value) when is_binary(value), do: Project.label_for(value)
  defp display_label(_value), do: "-"

  defp display_value(value) when is_list(value) and value != [], do: Enum.join(value, ", ")
  defp display_value(value) when is_binary(value), do: value
  defp display_value(_value), do: "-"
end
