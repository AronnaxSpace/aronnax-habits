import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lightBtn", "systemBtn", "darkBtn"]

  connect() {
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.systemChangeHandler = () => {
      if (this.#pref() === "system") this.#applyTheme("system")
    }
    this.mediaQuery.addEventListener("change", this.systemChangeHandler)
    const pref = this.#pref()
    this.#applyTheme(pref)
    this.#updateButtons(pref)
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this.systemChangeHandler)
  }

  setLight()  { this.#set("light") }
  setDark()   { this.#set("dark") }
  setSystem() { this.#set("system") }

  #pref() {
    return localStorage.getItem("theme") || "system"
  }

  #set(pref) {
    localStorage.setItem("theme", pref)
    this.#applyTheme(pref)
    this.#updateButtons(pref)
  }

  #applyTheme(pref) {
    const isDark = pref === "dark" ||
      (pref === "system" && this.mediaQuery.matches)
    document.documentElement.classList.toggle("dark", isDark)
  }

  #updateButtons(pref) {
    if (!this.hasLightBtnTarget) return
    const targets = {
      light: this.lightBtnTarget,
      system: this.systemBtnTarget,
      dark: this.darkBtnTarget,
    }
    Object.entries(targets).forEach(([key, el]) => {
      const active = key === pref
      el.classList.toggle("bg-white", active)
      el.classList.toggle("shadow-sm", active)
      el.classList.toggle("text-indigo-600", active)
      el.classList.toggle("text-gray-500", !active)
    })
  }
}
