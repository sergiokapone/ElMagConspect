"""Spot fixes for individual figures of the HTML site (read by publish_html.py).

IMG_STYLE: key = a fragment of the <img> src (file name); value = CSS appended to the inline style of that <img>
           (an inline !important beats the !important caps in conspect.css).
FIG_CLASS: key = label of the figure (anchor id, e.g. 'pic:TwoSurfaces'); value = CSS class added to the <div class="center">
           of that <figure> (the flex container of its sub-figures). Classes are defined in docs/assets/conspect.css:
           fig-row = the sub-figures share one row equally (captions wrap inside them).
Apply to already published pages without a rebuild:  python publish_html.py --patch-only
"""

IMG_STYLE = {
    'FaradayCage.jpg': 'width:75%; max-width:100% !important',      # рис. 4.5: у PDF 0.75 \linewidth
    'Mountain.jpg':    'width:100%; max-width:100% !important',     # рис. 14.8: у PDF на всю ширину
}

FIG_CLASS = {
    'pic:TwoSurfaces':       'fig-row',                             # рис. 14.3: дві панелі поруч, як у PDF
    'pic:StaticsComparison': 'fig-row',                             # рис. 14.7
}
