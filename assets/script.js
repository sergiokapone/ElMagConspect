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
})();
