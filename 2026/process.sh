# Download a copy of the reveal.js repo into this years folder
# e.g. into ./2026/revealjs/

# make a copy of revealjs' index.html
cp revealjs/index.html index.html
# adjust the paths so that it works on this folder level
perl -i -p -e 's/(href|src)="/$1="revealjs\//g;' index.html


# Now, work on the theater script:

# convert pdf to html (preserves bold)
pdftohtml -noframes -enc UTF-8 "Theater 2026 Die verschwundene Sternstunde.pdf" skript1.html

# fix italic spans in HTML: collapse <br/> inside <i> tags and merge adjacent <i> blocks
perl -i -0777 -p \
  -e 's{<i>(.*?)</i>}{my $t=$1; $t=~s/<br\/>/ /g; "<i>$t</i>"}gse;' \
  -e 's{</i>\s*(?:<br/>)?\s*\n?\s*<i>}{ }g;' \
  skript1.html

pandoc -f html -t markdown -o skript1.md skript1.html

# clean up skript1.md: replace non-breaking spaces (introduced by pandoc), remove page anchors
# and horizontal rules, and split on markdown hard line breaks (\<newline>)
perl -i -0777 -p \
  -e 's/\xc2\xa0/ /g;' \
  -e 's/\[\]\{#\d+\}//g;' \
  -e 's/^-{3,}\s*$//mg;' \
  -e 's/\\\n/\n\n/g;' \
  skript1.md

awk '{gsub(/([[:space:]])\*\*/, "\\1\n\n**"); print}' skript1.md > skript1b.md


# remove single linebreaks
awk 'BEGIN{ORS=RS="\n\n"} {gsub("\n", " "); print}' skript1b.md > skript2.md

# add +++++++ if the cummulative count of characters exceeds 120
awk -v limit=120 'BEGIN {ORS=RS="\n"} {
    count += length($0)
    if (NR == 1) {
        printf "\n+++++++\n%s\n\n", $0
    } else if (count >= limit) {
        printf "\n+++++++\n%s\n\n", $0
        count = 0
    } else {
        print $0
    }
}
END {
    if (NR > 1) {
        printf "\n+++++++\n\n"
    }
}' skript2.md > skript3.md

# replace the +++++++ with </section>\n<section class="marker_single">, except the first and the last
sed -e '0,/+++++++/s//<section class="marker_single">/' -e '$s//<\/section>/' -e 's/+++++++/<\/section>\n<section class="marker_single">/g' skript3.md > skript4.md

# convert to html
pandoc -f markdown -t html -o skript5.html skript4.md



# in index.html, delete the two example slides, then inject skript5.html after <div class="slides">
ed -s index.html <<EOF
22,23d
21r skript5.html
wq
EOF

# replace <strong> with <span class="s"> for speaker name styling
sed -i 's/<strong>/<span class="s">/g; s/<\/strong>/<\/span>/g' index.html

# now, do some manual cleaning and optionally style all "strong" tags (these are usually the)
# persons speaking, e.g. with the following css:
# strong{
#     color: #FFA500;
# }

# also, enable the search plugin (revealjs/plugin/search/search.js), by adding this path and
# enabling ReveaSearch
