# latexmk: the index of the book is sorted by upmendex with the Ukrainian style (not by makeindex,
# which latexmk would run by default and which does not sort Cyrillic correctly).
$makeindex = 'upmendex -s index-uk.ist %O -o %D %S';
