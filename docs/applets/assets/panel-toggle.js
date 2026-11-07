// Згортання панелі керування (#panel): кнопка зверху, решта вмісту ховається.
(function () {
  function init() {
    var p = document.getElementById('panel');
    if (!p || p.querySelector('.pt-btn')) return;
    var st = document.createElement('style');
    st.textContent =
      '.pt-btn{display:block;width:100%;text-align:left;font:inherit;font-weight:600;font-size:13px;' +
      'background:transparent;color:inherit;border:0;padding:0 0 2px;cursor:pointer}' +
      '#panel.collapsed>:not(.pt-btn){display:none!important}' +
      '#panel.collapsed{width:auto!important;max-width:none!important}' +
      '#panel.collapsed .pt-btn{padding:0}';
    document.head.appendChild(st);
    var b = document.createElement('button');
    b.type = 'button';
    b.className = 'pt-btn';
    function sync() {
      var c = p.classList.contains('collapsed');
      b.textContent = (c ? '▸ ' : '▾ ') + 'Керування';
      b.setAttribute('aria-expanded', c ? 'false' : 'true');
    }
    b.addEventListener('click', function () { p.classList.toggle('collapsed'); sync(); });
    p.insertBefore(b, p.firstChild);
    sync();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
