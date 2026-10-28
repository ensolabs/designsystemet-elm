/**
 * Open state for <dialog> and [popover], the one behaviour the Elm package
 * needs on top of @digdir/designsystemet-web.
 *
 * Dialogs and popovers only open through a method call (showModal(),
 * showPopover(), …), which Elm and other view libraries without refs can't
 * make. The view renders data-open="true" or "false" instead, and this
 * script calls the method to match:
 *
 *   <dialog data-open="true">              → showModal()
 *   <dialog data-open="true" data-modal="false"> → show()
 *   <div popover data-open="true">         → showPopover()
 *   data-open="false"                      → close() / hidePopover()
 *
 * When the user closes one (Escape, a close button, a click outside), the
 * element closes by itself. The view gets a `close` or `toggle` event and
 * should set its state to closed so the attribute matches again.
 *
 * Only data-open is watched: changing data-modal on an open dialog takes
 * effect the next time it opens.
 *
 * Also stops Escape from closing closedby="none" dialogs (Dialog.closedByNone)
 * in browsers without native closedby; designsystemet-web only polyfills
 * closedby="any".
 */

const ATTRIBUTE = "data-open";

const sync = (el) => {
  const state = el.getAttribute(ATTRIBUTE);
  if (state === null || !el.isConnected) return;
  const wanted = state === "true";
  try {
    if (el instanceof HTMLDialogElement) {
      if (wanted && !el.open) {
        if (el.getAttribute("data-modal") === "false") el.show();
        else el.showModal();
      } else if (!wanted && el.open) {
        el.close();
      }
    } else if (el.hasAttribute("popover")) {
      const shown = el.matches(":popover-open");
      if (wanted && !shown) el.showPopover();
      else if (!wanted && shown) el.hidePopover();
    }
  } catch (error) {
    // E.g. showModal() on a dialog already open non-modally. The next change
    // of data-open tries again.
    console.warn("designsystemet-elm: could not sync", ATTRIBUTE, "on", el, error);
  }
};

const syncTree = (node) => {
  if (node.nodeType !== Node.ELEMENT_NODE) return;
  if (node.hasAttribute(ATTRIBUTE)) sync(node);
  for (const el of node.querySelectorAll(`[${ATTRIBUTE}]`)) sync(el);
};

if (typeof window !== "undefined" && !window.__designsystemetElmOpenState) {
  window.__designsystemetElmOpenState = true;
  new MutationObserver((records) => {
    for (const record of records) {
      if (record.type === "attributes") sync(record.target);
      else for (const node of record.addedNodes) syncTree(node);
    }
  }).observe(document.documentElement, {
    subtree: true,
    childList: true,
    attributes: true,
    attributeFilter: [ATTRIBUTE],
  });
  syncTree(document.documentElement);

  // `cancel` doesn't bubble, so listen in the capture phase.
  document.addEventListener(
    "cancel",
    (event) => {
      const dialog = event.target;
      if (dialog instanceof HTMLDialogElement && dialog.getAttribute("closedby") === "none") {
        event.preventDefault();
      }
    },
    true,
  );
}
