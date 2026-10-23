/* book.js — необов'язкове покращення для HTML-версії книги.
   Без нього conspect.css працює повністю; зі скриптом додається:
   • бічний зміст розгортає лише поточний розділ (і підсвічує поточний параграф);
   • шухляда змісту на телефонах;
   • перемикач світлої/темної теми (запам'ятовується);
   • кнопки «попередній / наступний розділ» унизу сторінки;
   • пошук по тексту розділів (Pagefind: індекс pagefind/ будує build-html.ps1; потрібен вебсервер, не file://). */
(function () {
  'use strict';
  var root = document.documentElement;
  var KEY = 'elmag-book-theme';
  /* тека сайту (book.js лежить у assets/): там і pagefind/ */
  var SITE = ((document.currentScript && document.currentScript.src) || '').replace(/assets\/book\.js(\?.*)?$/, '');

  /* ── Тема ── */
  function setTheme(t) {
    root.classList.toggle('dark', t === 'dark');
        var b = document.querySelector('.theme-btn');
    if (b) { b.textContent = isDark() ? 'Світла тема' : 'Темна тема'; }
  }
  function isDark() { return root.classList.contains('dark'); }
  try { var saved = localStorage.getItem(KEY); if (saved) { setTheme(saved); } } catch (e) {}

  function init() {
    var title = document.querySelector('.sidetoctitle');
    if (title) {
      var tb = document.createElement('button');
      tb.type = 'button'; tb.className = 'theme-btn';
      tb.addEventListener('click', function () {
        var next = isDark() ? 'light' : 'dark';
        setTheme(next);
        try { localStorage.setItem(KEY, next); } catch (e) {}
      });
      title.appendChild(tb);
            tb.textContent = isDark() ? 'Світла тема' : 'Темна тема';
    }

    var box = document.querySelector('.sidetoccontents');
    if (!box) { return; }
    initSearch(box);

    /* ── Групи «розділ → параграфи» ── */
    var here = (location.pathname.split('/').pop() || '').toLowerCase();
    var groups = [], cur = null;
    box.querySelectorAll('p').forEach(function (p) {
      var a = p.querySelector('a'); if (!a) { return; }
      if (a.classList.contains('tocchapter')) {
        cur = { head: p, link: a, items: [], file: (a.getAttribute('href') || '').split('#')[0].toLowerCase() };
        groups.push(cur);
      } else if (a.classList.contains('tocsection') && cur) {
        cur.items.push(p);
      }
    });

    var openAll = false;
    var current = groups.filter(function (g) { return g.file === here; })[0];
    function render() {
      groups.forEach(function (g) {
        var show = openAll || g === current;
        g.items.forEach(function (p) { p.classList.toggle('toc-collapsed', !show); });
      });
    }
    if (current) { current.link.classList.add('is-current'); }
    render();

    var all = document.createElement('button');
    all.type = 'button'; all.className = 'toc-all'; all.textContent = 'Показати всі параграфи';
    all.addEventListener('click', function () {
      openAll = !openAll;
      all.textContent = openAll ? 'Лише поточний розділ' : 'Показати всі параграфи';
      render();
    });
    box.appendChild(all);
    if (current) { /* прокручуємо лише сам зміст, а не сторінку */
      var br = box.getBoundingClientRect(), lr = current.link.getBoundingClientRect();
      box.scrollTop += lr.top - br.top - box.clientHeight / 3;
    }

    /* ── Підсвічування поточного параграфа ── */
    var links = {};
    box.querySelectorAll('a[href*="#"]').forEach(function (a) {
      var h = a.getAttribute('href'), f = h.split('#')[0].toLowerCase();
      if (f === here) { links[h.split('#')[1]] = a; }
    });
    var heads = Array.prototype.slice.call(document.querySelectorAll('h3[id],h4[id]'))
      .filter(function (h) { return links[h.id]; });
    if ('IntersectionObserver' in window && heads.length) {
      var active = null;
      var io = new IntersectionObserver(function (es) {
        es.forEach(function (e) {
          if (e.isIntersecting) {
            if (active) { active.classList.remove('is-active'); }
            active = links[e.target.id]; active.classList.add('is-active');
          }
        });
      }, { rootMargin: '0px 0px -75% 0px' });
      heads.forEach(function (h) { io.observe(h); });
    }

    /* ── Попередній / наступний розділ ── */
    var bot = document.querySelector('.botnavigation');
    var idx = groups.indexOf(current);
    if (bot && idx >= 0) {
      function nav(g, cls, label) {
        var a = document.createElement('a');
        a.href = g.link.getAttribute('href'); a.className = cls;
        a.innerHTML = '<small>' + label + '</small>' + g.link.textContent.replace(/\s+/g, ' ').trim();
        return a;
      }
      var home = bot.querySelector('.linkhome');
      bot.textContent = '';
      if (groups[idx - 1]) { bot.appendChild(nav(groups[idx - 1], 'nav-prev', 'Попередній розділ')); }
      if (home) { bot.appendChild(home); }
      if (groups[idx + 1]) { bot.appendChild(nav(groups[idx + 1], 'nav-next', 'Наступний розділ')); }
    }

    /* ── Шухляда на вузьких екранах ── */
    var top = document.querySelector('.topnavigation');
    if (top) {
      var fab = document.createElement('button');
      fab.type = 'button'; fab.className = 'toc-fab'; fab.textContent = 'Зміст';
      fab.addEventListener('click', function () { root.classList.toggle('toc-open'); });
      top.appendChild(fab);
      box.addEventListener('click', function (e) { if (e.target.closest('a')) { root.classList.remove('toc-open'); } });
      document.body.addEventListener('click', function (e) {
        if (root.classList.contains('toc-open') && !e.target.closest('.sidetoccontainer, .toc-fab')) {
          root.classList.remove('toc-open');
        }
      });
    }
  }

  /* ── Пошук: поле над змістом; поки є запит, результати заступають зміст (conspect.css, #search) ── */
  function initSearch(box) {
    if (!SITE || location.protocol === 'file:') { return; }      /* Pagefind читає індекс через fetch */
    var sb = document.createElement('div');
    sb.id = 'search';
    box.parentNode.insertBefore(sb, box);
    var css = document.createElement('link');
    css.rel = 'stylesheet'; css.href = SITE + 'pagefind/pagefind-ui.css';
    document.head.appendChild(css);
    var js = document.createElement('script');
    js.src = SITE + 'pagefind/pagefind-ui.js';
    js.onerror = function () { sb.remove(); css.remove(); };    /* індексу немає (збірка без node) */
    js.onload = function () {
      var norm = function (x) { return (x || '').replace(/\s+/g, ' ').trim(); };
      new window.PagefindUI({
        element: '#search', showSubResults: true, showImages: false, resetFilters: false,
        baseUrl: new URL(SITE).pathname,                          /* сайт може лежати не в корені домену */
        processResult: function (r) {
          var t = norm(r.meta && r.meta.title);
          r.excerpt = texFix(r.excerpt);
          (r.sub_results || []).forEach(function (s) {
            s.excerpt = texFix(s.excerpt);
            if (norm(s.title) === t) { s.title = 'Початок розділу'; }  /* текст до першого параграфа */
          });
          return r;
        },
        translations: {
          placeholder: 'Пошук у книзі', clear_search: 'Очистити', load_more: 'Показати ще',
          search_label: 'Пошук у книзі', zero_results: 'Нічого не знайдено: «[SEARCH_TERM]»',
          many_results: 'Знайдено: [COUNT] — «[SEARCH_TERM]»', one_result: 'Знайдено: 1 — «[SEARCH_TERM]»',
          alt_search: 'Нічого не знайдено: «[SEARCH_TERM]». Результати для «[DIFFERENT_TERM]»',
          search_suggestion: 'Нічого не знайдено: «[SEARCH_TERM]». Спробуйте інший запит:',
          searching: 'Шукаю «[SEARCH_TERM]»…'
        }
      });
      typesetResults(sb);
    };
    document.head.appendChild(js);
    /* на телефоні перехід до результату закриває шухляду */
    sb.addEventListener('click', function (e) { if (e.target.closest('a')) { root.classList.remove('toc-open'); } });
  }

  /* Уривок обрізано посеред формули: прибираємо «висячі» \( \) і \begin{..} \end{..} з країв, щоб решту зверстав MathJax */
  function texFix(html) {
    if (!html) { return html; }
    var o = html.indexOf('\\('), c = html.indexOf('\\)');
    if (c >= 0 && (o < 0 || c < o)) { html = '…' + html.slice(c + 2); }
    o = html.lastIndexOf('\\('); c = html.lastIndexOf('\\)');
    if (o > c) { html = html.slice(0, o) + '…'; }
    var b = html.lastIndexOf('\\begin{'), e = html.lastIndexOf('\\end{');
    if (b > e) { html = html.slice(0, b) + '…'; }
    var e0 = html.indexOf('\\end{'), b0 = html.indexOf('\\begin{');
    if (e0 >= 0 && (b0 < 0 || e0 < b0)) { html = '…' + html.slice(html.indexOf('}', e0) + 1); }
    return html;
  }

  /* Формули в результатах: після кожного оновлення списку — MathJax (свої зміни MathJax не рахуються) */
  function typesetResults(sb) {
    var timer = null, running = false, again = false;
    function schedule() { if (timer) { clearTimeout(timer); } timer = setTimeout(run, 120); }
    function run() {
      timer = null;
      if (running) { again = true; return; }
      if (!window.MathJax || !MathJax.typesetPromise) { timer = setTimeout(run, 400); return; }
      running = true;
      var p;
      try { if (MathJax.typesetClear) { MathJax.typesetClear([sb]); } p = MathJax.typesetPromise([sb]); }
      catch (e) { running = false; return; }
      p.catch(function () {}).then(function () { running = false; if (again) { again = false; schedule(); } });
    }
    new MutationObserver(function (ms) {
      /* кнопка «Очистити» — лише хрестик (conspect.css), підпис стає підказкою */
      var cl = sb.querySelector('.pagefind-ui__search-clear');
      if (cl && !cl.title) { cl.title = (cl.textContent || '').trim(); }
      for (var i = 0; i < ms.length; i++) {
        var t = ms[i].target;
        if (t.nodeType === 1 && t.closest && t.closest('mjx-container')) { continue; }
        schedule(); return;
      }
    }).observe(sb, { childList: true, subtree: true });
  }

  if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', init); } else { init(); }
})();
