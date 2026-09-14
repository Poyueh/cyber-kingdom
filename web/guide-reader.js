/* Web-only reader. Godot opens it from the already-paused campaign menu. */
(() => {
  const dialog = document.createElement('dialog');
  dialog.id = 'player-guide';
  dialog.setAttribute('aria-labelledby', 'player-guide-title');
  dialog.innerHTML = `
    <header class="guide-toolbar">
      <span id="player-guide-title">騎士野外手冊</span>
      <button type="button" class="guide-close" aria-label="關閉指南，回到暫停選單" title="關閉指南（Esc）" autofocus>
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18"/></svg>
      </button>
    </header>
    <p class="guide-loading" role="status">正在開啟手冊…</p>
    <iframe title="Cyber Kingdom 玩家圖文指南" referrerpolicy="same-origin"></iframe>`;
  document.body.append(dialog);
  const frame = dialog.querySelector('iframe');
  const closeButton = dialog.querySelector('button');
  const loading = dialog.querySelector('.guide-loading');
  const canvas = document.querySelector('canvas');

  function close() {
    if (!dialog.open) return;
    dialog.close();
    canvas?.focus({ preventScroll: true });
    // Keep Godot paused; the player explicitly resumes using the existing menu.
  }

  function onKey(event) {
    if (!dialog.open) return;
    if (event.key === 'Escape') {
      event.preventDefault();
      event.stopImmediatePropagation();
      close();
    } else {
      // Browser scrolling/tabbing still works; keys never reach the game canvas.
      event.stopPropagation();
    }
  }
  dialog.addEventListener('keydown', onKey);
  dialog.addEventListener('keyup', event => event.stopPropagation());
  dialog.addEventListener('cancel', event => { event.preventDefault(); close(); });
  closeButton.addEventListener('click', close);
  frame.addEventListener('load', () => {
    loading.hidden = true;
    // The guide is bundled on this origin. Catch Escape even while reading inside it.
    frame.contentDocument?.addEventListener('keydown', onKey, true);
  });

  window.CyberKingdomGuide = Object.freeze({
    open() {
      if (dialog.open) return;
      dialog.showModal();
      if (!frame.hasAttribute('src')) frame.src = 'guide.html';
      closeButton.focus({ preventScroll: true });
    }
  });
})();
