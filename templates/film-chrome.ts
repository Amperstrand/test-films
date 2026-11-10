// film-chrome — drop-in movie chrome for a browser test recording.
//
// Gives one continuous phone-viewport film: readable text cards with
// computed pacing, cross-fades, a phone frame with status bar, a
// deliberate fade-out, and a narration timeline the post pass
// (tools/narrate-film.sh) consumes. Project views (companion strips,
// device panels) extend this; see docs/08-overlays.md for their rules.
//
// Usage from a spec:
//   import { installChrome, card, hideCard, cardUntil, fadeOut,
//            writeTimeline, still } from "<path>/film-chrome"
// Paste into the spec instead if cross-tree imports do not fit the
// runner; this file is the canonical source to copy from.

import fs from "node:fs"
import path from "node:path"
import type { Page } from "@playwright/test"

export const CHROME_CSS = `
  #movie-card {
    position: fixed; inset: 0; z-index: 2147483646;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    gap: 18px; padding: 32px; text-align: center;
    background: radial-gradient(120% 120% at 50% 0%, #0b1220 0%, #050810 70%);
    color: #e6edf3; font-family: Inter, system-ui, sans-serif;
    opacity: 0; transition: opacity .45s ease;
  }
  #movie-card.show { opacity: 1; }
  #movie-card .title { font-size: 30px; font-weight: 700; letter-spacing: -.02em; line-height: 1.25; max-width: 340px; }
  #movie-card .body { font-size: 17px; line-height: 1.5; color: #9fb0c3; max-width: 330px; }
  #movie-card .brand { position: absolute; bottom: 26px; font-size: 12px; color: #5b6b7f; letter-spacing: .14em; }
  #movie-frame {
    position: fixed; inset: 0; z-index: 2147483643; pointer-events: none;
    border: 7px solid #0a0d14; border-radius: 26px;
    box-shadow: inset 0 0 0 1.5px rgba(120,140,170,.35), 0 0 0 1px rgba(0,0,0,.8);
  }
  #movie-statusbar {
    position: fixed; top: 0; left: 0; right: 0; height: 22px; z-index: 2147483643;
    pointer-events: none; display: flex; align-items: center; justify-content: space-between;
    padding: 0 16px; box-sizing: border-box;
    color: #e6edf3; font-family: Inter, system-ui, sans-serif; font-size: 11px; font-weight: 600;
    text-shadow: 0 1px 2px rgba(0,0,0,.6);
  }
  #movie-fade {
    position: fixed; inset: 0; z-index: 2147483647; background: #000;
    opacity: 0; transition: opacity 1.4s ease; pointer-events: none;
  }
`

// Reading-speed pacing: ~3 words/second plus entry slack, floored.
export function holdFor(...texts: (string | undefined)[]): number {
  const words = texts.join(" ").split(/\s+/).filter(Boolean).length
  return Math.max(3_200, 1_400 + words * 450)
}

export async function installChrome(page: Page) {
  await page.addStyleTag({ content: CHROME_CSS })
  await page.evaluate(() => {
    for (const [id, html] of [
      ["movie-fade", ""],
      ["movie-frame", ""],
      ["movie-statusbar", "<span>9:41</span><span>▮▮▮ ⌁ 84%</span>"],
    ] as const) {
      if (!document.getElementById(id)) {
        const el = document.createElement("div")
        el.id = id
        el.innerHTML = html
        document.body.appendChild(el)
      }
    }
  })
}

const TIMELINE: { start: number; end?: number; say?: string }[] = []
let T0 = 0
function markStart(say?: string) {
  if (!T0) T0 = Date.now()
  TIMELINE.push({ start: Date.now() - T0, say })
}
function markEnd() {
  const last = TIMELINE[TIMELINE.length - 1]
  if (last && last.end === undefined) last.end = Date.now() - T0
}

export async function card(
  page: Page,
  opts: { title?: string; body?: string; qrDataUrl?: string; holdMs?: number; brand?: boolean; say?: string },
) {
  await page.evaluate(
    ({ title, body, qrDataUrl, brand }) => {
      document.getElementById("movie-card")?.remove()
      const el = document.createElement("div")
      el.id = "movie-card"
      const titleEl = title ? `<div class="title">${title}</div>` : ""
      const bodyEl = body ? `<div class="body">${body}</div>` : ""
      const qrEl = qrDataUrl
        ? `<img src="${qrDataUrl}" width="200" height="200" alt="QR" />`
        : ""
      const brandEl = brand === false ? "" : `<div class="brand">${brand ?? ""}</div>`
      el.innerHTML = `${titleEl}${bodyEl}${qrEl}${brandEl}`
      document.body.appendChild(el)
      requestAnimationFrame(() => el.classList.add("show"))
    },
    { title: opts.title, body: opts.body, qrDataUrl: opts.qrDataUrl, brand: opts.brand },
  )
  markStart(opts.say)
  await page.waitForTimeout(opts.holdMs ?? holdFor(opts.title, opts.body))
  markEnd()
}

// A card that stays up until a predicate passes — bridges system
// waits (settlements, syncs) with live status instead of dead air.
export async function cardUntil(
  page: Page,
  opts: { title: string; body: string; done: string; say?: string },
  predicate: () => Promise<boolean>,
  timeoutMs: number,
) {
  await page.evaluate(
    ({ title, body }) => {
      document.getElementById("movie-card")?.remove()
      const el = document.createElement("div")
      el.id = "movie-card"
      el.innerHTML = `<div class="title">${title}</div><div class="body">${body}</div>`
      document.body.appendChild(el)
      requestAnimationFrame(() => el.classList.add("show"))
    },
    opts,
  )
  markStart(opts.say)
  const deadline = Date.now() + timeoutMs
  while (!(await predicate())) {
    if (Date.now() > deadline) throw new Error(`cardUntil timeout: ${opts.title}`)
    await page.waitForTimeout(500)
  }
  await page.evaluate(done => {
    const el = document.getElementById("movie-card")
    if (el) el.querySelector(".body")!.textContent = done
  }, opts.done)
  await page.waitForTimeout(2_200)
  markEnd()
}

export async function hideCard(page: Page) {
  await page.evaluate(
    () =>
      new Promise<void>(resolve => {
        const el = document.getElementById("movie-card")
        if (!el) return resolve()
        el.classList.remove("show")
        setTimeout(() => {
          el.remove()
          resolve()
        }, 480)
      }),
  )
}

export async function fadeOut(page: Page) {
  await page.evaluate(
    () =>
      new Promise<void>(resolve => {
        const el = document.getElementById("movie-fade")
        if (el) el.style.opacity = "1"
        setTimeout(resolve, 1_600)
      }),
  )
}

export function writeTimeline(path = "e2e/.results-video/movie-timeline.json") {
  markEnd()
  fs.mkdirSync(path.dirname(path), { recursive: true })
  fs.writeFileSync(path, JSON.stringify({ entries: TIMELINE }, null, 2))
}

export async function still(page: Page, path: string) {
  await page.screenshot({ path })
}
