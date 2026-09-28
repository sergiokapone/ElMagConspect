(function () {
    'use strict';

    /* ═══════════════════════════════════════════════════════════
       Перемикач теми (світла/темна), збереження в localStorage.
       ═══════════════════════════════════════════════════════════ */
    var THEME_KEY = 'elmag-theme';
    var themeToggle = document.getElementById('theme-toggle');

    function applyTheme(theme) {
        document.documentElement.classList.toggle('dark', theme === 'dark');
        if (themeToggle) {
            themeToggle.textContent = theme === 'dark' ? '☀️' : '🌙';
        }
    }

    var savedTheme = null;
    try { savedTheme = localStorage.getItem(THEME_KEY); } catch (e) { /* localStorage недоступний */ }

    if (!savedTheme && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        savedTheme = 'dark';
    }
    applyTheme(savedTheme === 'dark' ? 'dark' : 'light');

    if (themeToggle) {
        themeToggle.addEventListener('click', function () {
            var next = document.documentElement.classList.contains('dark') ? 'light' : 'dark';
            applyTheme(next);
            try { localStorage.setItem(THEME_KEY, next); } catch (e) { /* ignore */ }
        });
    }

    /* ═══════════════════════════════════════════════════════════
       Зміст у стилі друкованої книги:
       кожен пункт отримує рядок [номер] [назва] [·····крапки·····] [▸],
       де стрілка — це акордеон для підпунктів (якщо вони є).
       Клік по назві, як і раніше, веде у PDF; клік по стрілці —
       розгортає/згортає підрозділи.
       ═══════════════════════════════════════════════════════════ */
    var TOC_STATE_KEY = 'elmag-toc-expanded';
    var chevronSVG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" ' +
        'stroke-linecap="round" stroke-linejoin="round"><polyline points="9 6 15 12 9 18"></polyline></svg>';

    function buildToc() {
        var items = document.querySelectorAll('.toc-list > li');
        var accordionItems = [];

        items.forEach(function (li) {
            var num = li.querySelector(':scope > .toc-num');
            var titleLink = li.querySelector(':scope > .toc-title');
            var subList = li.querySelector(':scope > .sub-list');

            if (!titleLink) { return; }

            // Рядок пункту змісту: номер + назва + крапковий "лідер" + (стрілка)
            var row = document.createElement('div');
            row.className = 'toc-row';

            if (num) { row.appendChild(num); }
            row.appendChild(titleLink);

            var dots = document.createElement('span');
            dots.className = 'toc-dots';
            dots.setAttribute('aria-hidden', 'true');
            row.appendChild(dots);

            if (subList) {
                var toggleBtn = document.createElement('button');
                toggleBtn.type = 'button';
                toggleBtn.className = 'toc-toggle';
                toggleBtn.innerHTML = chevronSVG;
                toggleBtn.setAttribute('aria-expanded', 'false');
                toggleBtn.setAttribute('aria-label', 'Розгорнути підрозділи');
                row.appendChild(toggleBtn);

                li.insertBefore(row, subList);

                var wrap = document.createElement('div');
                wrap.className = 'sub-list-wrap';
                li.replaceChild(wrap, subList);
                wrap.appendChild(subList);
                wrap.style.maxHeight = '0px';

                (function (li, wrap, subList, toggleBtn) {
                    function setOpen(open) {
                        li.classList.toggle('toc-open', open);
                        toggleBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
                        toggleBtn.setAttribute('aria-label', open ? 'Згорнути підрозділи' : 'Розгорнути підрозділи');
                        wrap.style.maxHeight = open ? (subList.scrollHeight + 12) + 'px' : '0px';
                    }
                    toggleBtn.addEventListener('click', function () {
                        setOpen(!li.classList.contains('toc-open'));
                    });
                    accordionItems.push({ li: li, setOpen: setOpen });
                })(li, wrap, subList, toggleBtn);
            } else {
                li.classList.add('no-sub');
                li.appendChild(row);
            }
        });

        // Кнопки "Розгорнути все" / "Згорнути все"
        var expandAllBtn = document.getElementById('toc-expand-all');
        var collapseAllBtn = document.getElementById('toc-collapse-all');

        function setAll(open) {
            accordionItems.forEach(function (item) { item.setOpen(open); });
            try { localStorage.setItem(TOC_STATE_KEY, open ? '1' : '0'); } catch (e) { /* ignore */ }
        }

        if (expandAllBtn) {
            expandAllBtn.addEventListener('click', function () { setAll(true); });
        }
        if (collapseAllBtn) {
            collapseAllBtn.addEventListener('click', function () { setAll(false); });
        }

        // Перерахунок max-height при зміні розміру вікна (перенесення рядків тексту)
        window.addEventListener('resize', function () {
            accordionItems.forEach(function (item) {
                if (item.li.classList.contains('toc-open')) {
                    var wrap = item.li.querySelector(':scope > .sub-list-wrap');
                    var subList = wrap.querySelector('.sub-list');
                    wrap.style.maxHeight = (subList.scrollHeight + 12) + 'px';
                }
            });
        });

        // Відновлюємо попередній стан "розгорнуто все", якщо він був збережений
        var savedState = null;
        try { savedState = localStorage.getItem(TOC_STATE_KEY); } catch (e) { /* ignore */ }
        if (savedState === '1') { setAll(true); }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', buildToc);
    } else {
        buildToc();
    }

    /* ═══════════════════════════════════════════════════════════
       Кнопка "Нагору"
       ═══════════════════════════════════════════════════════════ */
    var backToTop = document.getElementById('back-to-top');
    if (backToTop) {
        window.addEventListener('scroll', function () {
            backToTop.classList.toggle('visible', window.scrollY > 400);
        });
        backToTop.addEventListener('click', function () {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }

    /* ═══════════════════════════════════════════════════════════
       Перемикач дизайнів: Поле / Креслення / Книга.
       Вибір зберігається в localStorage (ключ elmag-design).
       ═══════════════════════════════════════════════════════════ */
    var DESIGN_KEY = 'elmag-design';
    var DESIGNS = ['field', 'blueprint', 'book'];
    var root = document.documentElement;
    var designBtns = document.querySelectorAll('.design-switch button');

    function applyDesign(d) {
        if (DESIGNS.indexOf(d) < 0) { d = 'field'; }
        root.setAttribute('data-design', d);
        designBtns.forEach(function (b) {
            b.setAttribute('aria-pressed', b.getAttribute('data-design') === d ? 'true' : 'false');
        });
        // Змінилась геометрія — змісту й полотну треба перерахуватися
        window.dispatchEvent(new Event('resize'));
    }

    var savedDesign = null;
    try { savedDesign = localStorage.getItem(DESIGN_KEY); } catch (e) { /* ignore */ }
    applyDesign(savedDesign);

    designBtns.forEach(function (b) {
        b.addEventListener('click', function () {
            var d = b.getAttribute('data-design');
            applyDesign(d);
            try { localStorage.setItem(DESIGN_KEY, d); } catch (e) { /* ignore */ }
        });
    });

    /* ═══════════════════════════════════════════════════════════
       Силові лінії диполя в шапці. Додатний заряд нерухомий,
       від'ємний іде за курсором (або пальцем).
       ═══════════════════════════════════════════════════════════ */
    (function initField() {
        var hero = document.querySelector('.pdf-hero');
        if (!hero) { return; }

        var cv = document.createElement('canvas');
        cv.className = 'field-canvas';
        cv.setAttribute('aria-hidden', 'true');
        hero.insertBefore(cv, hero.firstChild);

        var ctx = cv.getContext('2d');
        var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        var w = 0, h = 0, dpr = 1, raf = 0;
        var P = { x: 0.72, y: 0.34 };            // + (частки розміру шапки)
        var N = { x: 0.9, y: 0.62 };             // − (поточне положення)
        var T = { x: 0.9, y: 0.62 };             // − (ціль руху)

        function field(x, y, p, n) {
            var ax = x - p.x, ay = y - p.y, bx = x - n.x, by = y - n.y;
            var ra = Math.pow(ax * ax + ay * ay, 1.5) || 1;
            var rb = Math.pow(bx * bx + by * by, 1.5) || 1;
            return [ax / ra - bx / rb, ay / ra - by / rb];
        }

        function draw() {
            if (!w || !cv.offsetParent) { return; }
            var cs = getComputedStyle(root);
            var line = cs.getPropertyValue('--fl-line');
            var cPos = cs.getPropertyValue('--fl-pos');
            var cNeg = cs.getPropertyValue('--fl-neg');
            var p = { x: P.x * w, y: P.y * h }, n = { x: N.x * w, y: N.y * h };

            ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
            ctx.clearRect(0, 0, w, h);
            ctx.lineWidth = 1.1;
            ctx.strokeStyle = line;
            ctx.beginPath();
            var lines = 28;
            for (var i = 0; i < lines; i++) {
                var a = i / lines * 2 * Math.PI;
                var x = p.x + Math.cos(a) * 10, y = p.y + Math.sin(a) * 10;
                ctx.moveTo(x, y);
                for (var s = 0; s < 700; s++) {
                    var f = field(x, y, p, n), m = Math.hypot(f[0], f[1]);
                    if (!m) { break; }
                    x += f[0] / m * 5; y += f[1] / m * 5;
                    ctx.lineTo(x, y);
                    if (Math.hypot(x - n.x, y - n.y) < 10 || x < -20 || x > w + 20 || y < -20 || y > h + 20) { break; }
                }
            }
            ctx.stroke();

            [[p, cPos, true], [n, cNeg, false]].forEach(function (c) {
                ctx.fillStyle = c[1];
                ctx.beginPath(); ctx.arc(c[0].x, c[0].y, 9, 0, 2 * Math.PI); ctx.fill();
                ctx.strokeStyle = '#fff'; ctx.lineWidth = 2; ctx.beginPath();
                ctx.moveTo(c[0].x - 4, c[0].y); ctx.lineTo(c[0].x + 4, c[0].y);
                if (c[2]) { ctx.moveTo(c[0].x, c[0].y - 4); ctx.lineTo(c[0].x, c[0].y + 4); }
                ctx.stroke();
            });
        }

        function frame() {
            var k = reduce ? 1 : 0.12;
            var dx = T.x - N.x, dy = T.y - N.y;
            N.x += dx * k; N.y += dy * k;
            draw();
            raf = (Math.abs(dx) + Math.abs(dy) > 0.0004) ? requestAnimationFrame(frame) : 0;
        }

        function resize() {
            var r = hero.getBoundingClientRect();
            dpr = Math.min(window.devicePixelRatio || 1, 2);
            w = r.width; h = r.height;
            cv.width = Math.round(w * dpr);
            cv.height = Math.round(h * dpr);
            draw();
        }

        hero.addEventListener('pointermove', function (e) {
            var r = hero.getBoundingClientRect();
            T.x = Math.min(0.98, Math.max(0.02, (e.clientX - r.left) / r.width));
            T.y = Math.min(0.98, Math.max(0.02, (e.clientY - r.top) / r.height));
            if (!raf) { raf = requestAnimationFrame(frame); }
        });

        window.addEventListener('resize', resize);
        if (themeToggle) { themeToggle.addEventListener('click', draw); }
        if (document.fonts && document.fonts.ready) {
            document.fonts.ready.then(function () { window.dispatchEvent(new Event('resize')); });
        }
        resize();
    })();
})();
