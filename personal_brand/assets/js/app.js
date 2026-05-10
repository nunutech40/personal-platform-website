// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/personal_brand"

const escapeHtml = value => value
  .replace(/&/g, "&amp;")
  .replace(/</g, "&lt;")
  .replace(/>/g, "&gt;")
  .replace(/"/g, "&quot;")
  .replace(/'/g, "&#039;")

const markdownInlineToHtml = value => escapeHtml(value)
  .replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img alt="$1" src="$2">')
  .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
  .replace(/`([^`]+)`/g, "<code>$1</code>")
  .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
  .replace(/\*([^*]+)\*/g, "<em>$1</em>")

const markdownToHtml = source => {
  const lines = source.split(/\r?\n/)
  const html = []
  let inList = false

  lines.forEach(line => {
    const trimmed = line.trim()

    if (trimmed.startsWith("- ")) {
      if (!inList) {
        html.push("<ul>")
        inList = true
      }

      html.push(`<li>${markdownInlineToHtml(trimmed.slice(2))}</li>`)
      return
    }

    if (inList) {
      html.push("</ul>")
      inList = false
    }

    if (trimmed === "") {
      return
    }

    if (trimmed.startsWith("### ")) {
      html.push(`<h3>${markdownInlineToHtml(trimmed.slice(4))}</h3>`)
    } else if (trimmed.startsWith("## ")) {
      html.push(`<h2>${markdownInlineToHtml(trimmed.slice(3))}</h2>`)
    } else if (trimmed.startsWith("# ")) {
      html.push(`<h1>${markdownInlineToHtml(trimmed.slice(2))}</h1>`)
    } else if (trimmed.startsWith("> ")) {
      html.push(`<blockquote>${markdownInlineToHtml(trimmed.slice(2))}</blockquote>`)
    } else {
      html.push(`<p>${markdownInlineToHtml(trimmed)}</p>`)
    }
  })

  if (inList) {
    html.push("</ul>")
  }

  return html.join("")
}

const AdminMarkdownEditor = {
  mounted() {
    this.textarea = this.el.querySelector("textarea")
    this.preview = this.el.querySelector("[data-md-preview]")
    this.previewVisible = false

    this.el.querySelectorAll("[data-md-action]").forEach(button => {
      button.addEventListener("click", event => {
        event.preventDefault()
        this.runAction(button.dataset.mdAction)
      })
    })

    if (this.textarea) {
      this.textarea.addEventListener("input", () => this.updatePreview())
    }
  },

  runAction(action) {
    if (!this.textarea) return

    if (action === "preview") {
      this.previewVisible = !this.previewVisible
      this.preview.classList.toggle("hidden", !this.previewVisible)
      this.el.querySelector("[data-md-action='preview']").classList.toggle("is-active", this.previewVisible)
      this.updatePreview()
      return
    }

    const actions = {
      heading: () => this.prefixLine("## "),
      bold: () => this.wrapSelection("**", "**", "bold text"),
      italic: () => this.wrapSelection("*", "*", "italic text"),
      link: () => this.wrapSelection("[", "](https://example.com)", "link text"),
      list: () => this.prefixLine("- "),
      code: () => this.wrapSelection("`", "`", "code"),
      image: () => this.insertText("![Alt text](https://example.com/image.jpg)")
    }

    actions[action]?.()
  },

  wrapSelection(before, after, fallback) {
    const start = this.textarea.selectionStart
    const end = this.textarea.selectionEnd
    const selected = this.textarea.value.slice(start, end) || fallback
    this.replaceSelection(`${before}${selected}${after}`, start + before.length, start + before.length + selected.length)
  },

  prefixLine(prefix) {
    const value = this.textarea.value
    const start = value.lastIndexOf("\n", this.textarea.selectionStart - 1) + 1
    const end = value.indexOf("\n", this.textarea.selectionEnd)
    const lineEnd = end === -1 ? value.length : end
    const selected = value.slice(start, lineEnd)
    const replacement = selected
      .split("\n")
      .map(line => line.startsWith(prefix) ? line : `${prefix}${line}`)
      .join("\n")

    this.textarea.setSelectionRange(start, lineEnd)
    this.replaceSelection(replacement, start, start + replacement.length)
  },

  insertText(text) {
    this.replaceSelection(text, this.textarea.selectionStart, this.textarea.selectionStart + text.length)
  },

  replaceSelection(text, selectionStart, selectionEnd) {
    this.textarea.setRangeText(text, this.textarea.selectionStart, this.textarea.selectionEnd, "end")
    this.textarea.dispatchEvent(new Event("input", {bubbles: true}))
    this.textarea.dispatchEvent(new Event("change", {bubbles: true}))
    this.textarea.focus()
    this.textarea.setSelectionRange(selectionStart, selectionEnd)
    this.updatePreview()
  },

  updatePreview() {
    if (!this.preview || !this.previewVisible) return

    const value = this.textarea.value.trim()
    this.preview.innerHTML = value
      ? markdownToHtml(value)
      : '<p class="admin-markdown-preview-empty">Nothing to preview yet.</p>'
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, AdminMarkdownEditor},
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}
