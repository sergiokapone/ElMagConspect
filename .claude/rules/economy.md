# Economy of context (the author is on a Pro plan: a 5-hour window plus a weekly limit)

Every request resends the whole context, and what was read stays there until `/clear`. The cheapest token is the one never read.

- Small edit: `grep -n` the anchor, then Read with offset/limit (~100 lines). A whole-chapter read is only for `/review-chapter` and for questions about the whole chapter, and then once.
- Never read whole: `REVIEW.md`, `main.log`, latexmk output. Use `grep -n` / `tail -n 40`.
- Review remarks are one small file per chapter: `review/<Folder>.md`. Open only the chapter in hand. Add remarks by appending with Bash (`>>`), not by rewriting the file.
- Big `.tex` (ElMagInduction is ~120 KB): ranges of 100--120 lines, one pass, no second read. After `/compact` do not re-read a file whole.
  Reason for «Autocompact is thrashing»: after compaction the harness puts the earlier-read files back; a big chapter plus a big remarks file overflow the window.
- Build and log output goes through a filter: `... 2>&1 | tail -n 40` or grep for `Overfull|Error|^!`.
- Layout check: view only the PNG pages with the changed place.
- Build one chapter (`chapter.py`), the whole book only at the end of a round and only when asked. Do not rebuild "to be sure"; do not re-read a file you just edited.
- Report briefly: what changed, what is left, at most one question.
