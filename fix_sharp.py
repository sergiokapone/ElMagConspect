import os
import re


def fix_lwarp_html(filepath: str):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Замена обратных слэшей в путях к файлам (src="..." и href="...")
    def fix_url_path(m):
        attr, quote, path = m.group(1), m.group(2), m.group(3)
        return f'{attr}={quote}{path.replace("\\", "/")}{quote}'

    content = re.sub(
        r'\b(src|href)=(["\'])([^"\']*?\\[^"\']*?)\2', fix_url_path, content
    )

    # 2. Исправление двойных решёток ##1, ##2 -> #1, #2 в макросах MathJax
    content = re.sub(r'##(\d)', r'#\1', content)

    # 3. Исправление комментариев HTML (-^-> -> -->)
    content = re.sub(r'-\^->', '-->', content)

    # 4. Удаление паразитных кареток ^ перед спецсимволами
    content = re.sub(r'\^([/<>=+#%])', r'\1', content)
    content = re.sub(r'https?:\^//', 'https://', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f'Исправлен: {filepath}')


# Обработка всех .html файлов в текущей директории
for root, _, files in os.walk('.'):
    for file in files:
        if file.endswith('.html'):
            fix_lwarp_html(os.path.join(root, file))

