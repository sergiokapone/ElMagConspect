# Economy of context (the author works on a Pro plan with a 5-hour limit)

- Do not read a whole chapter for a small edit: `grep -n` for the anchor, then view a line range.
  A full read is only for `/review-chapter` and for questions about the whole chapter.
- Never `cat` / read whole: `review-remarks.md`, `REVIEW.md`, `main.log`, latexmk output. Use `grep` / `tail -n 40`.
- Layout check: view only the PNG pages that contain the changed place, not all pages of the chapter.
- Build a single chapter (`chapter.py`), not the whole book, unless asked. The whole book only at the end of a round.
- Do not re-read a file you edited a moment ago; do not repeat a build "to be sure".
- Report results briefly: what changed, what is left, one question at most.
