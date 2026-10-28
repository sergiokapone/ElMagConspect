---
name: review-chapter
description: Review one chapter of the ElMagConspect textbook (physics, pedagogy, Ukrainian language, layout): write numbered remarks, agree them with the author, apply the agreed edits, check the layout. Use when the user asks to review, re-read or check a chapter.
argument-hint: <ChapterFolder, e.g. SteadyCurrent>
disable-model-invocation: true
---

Review the chapter `$ARGUMENTS` (a folder name from `main.tex`; if it is empty or not in `main.tex`, ask which chapter).
Work in stages and stop at the marked points: the author decides what is changed.

## 1. Prepare (read only)
- Read `$ARGUMENTS/$ARGUMENTS.tex` completely, once (if one Read is too small, consecutive ranges of ~250 lines; never twice).
  Read `.claude/rules/conventions.md` unless it already loaded with the `.tex`. `STATUS.md` is already imported: do not re-read it.
- Check whether `review/$ARGUMENTS.md` exists: if it does, this is a repeat review; read that file (it is small) and do not re-raise items
  marked [-] (the author kept them) or [+] (done).
- Skim the neighbouring chapters' relevant paragraphs only when the text refers to them (notation, results used earlier).

## 2. Analyse (four passes, do not mix)
1. **Physics.** Recompute every number, estimate and answer. Check limits of applicability, signs, factors (ε, 4π, c, 2),
   consistency with the unit system of the part, consistency with earlier chapters, historical facts, figure vs text.
   Use the checklist at the end of `conventions.md`.
2. **Pedagogy** (2nd-year applied physicists): order of exposition, undefined terms, jumps in derivations, missing motivation,
   what a student would ask. Propose, do not rewrite.
3. **Language** (Ukrainian): grammar, style, agreed terminology, repeated words, `~---`, `\S~\ref`.
4. **Source and layout:** labels and refs, environments, `[unbreakable]` on short boxes, the problems group, answers commented out,
   print-only commands missing from `ConspectBookHTML.cls`.

## 3. Write the remarks (do not edit the chapter yet)
- Write the remarks to `review/$ARGUMENTS.md` (create it with the heading `## $ARGUMENTS` if absent; on a repeat review append a new block with Bash `>>` and
  continue the numbering; never rewrite the file): numbered items in Ukrainian,
  each with the line number or a short anchor quote, what is wrong, and a concrete proposed fix. All start as `[?]`.
- Order by weight: errors first, then clarity, then style. Do not pad: no remark means it is fine.
- Tell the author (in Russian): the count by weight, the 3-5 most important items, and ask for decisions. **Stop here.**

## 4. After the author's decisions
- Do not re-read the chapter in full: `grep -n` the anchor quote from the remark, Read ~60 lines around it, Edit.
- Apply only what was agreed. Mark each item `[+]` (done), `[~]` (done differently: say how), `[-]` (author kept as is).
- New figures or boxes: define the commands for the HTML class too.
- Check the layout: `python chapter.py $ARGUMENTS --png`; look at the PNGs (widows, split boxes, overfull). Fix and rebuild.
- Do not edit chapter sources while a full-book build is running.

## 5. Close
- Add or update the chapter's row in `REVIEW.md` (find the row with `grep -n`, never read the whole file) (the main changes, one line; the commit hash is added by the author after the commit).
- Update `.claude/STATUS.md`: new open items, new disagreements, what remains to be done. Keep it within ~40 lines: drop finished items, do not keep a chronological log (history is in `REVIEW.md` and `git log`).
- Do not commit or push unless asked.
