

# convert docx to markdown
pandoc -f docx -t markdown -o skript.md Kopie\ von\ Theater\ 2023.2\ Kopie.docx

# remove single linebreaks
awk 'BEGIN{ORS=RS="\n\n"} {gsub("\n", " "); print}' skript.md > skript2.md

# add %%%%%% if the cummulative count of characters exceeds 150
awk -v limit=150 'BEGIN {ORS=RS="\n"} {
    count += length($0)
    if (NR == 1) {
        printf "\n%%%%%%%\n%s\n\n", $0
    } else if (count >= limit) {
        printf "\n%%%%%%%\n%s\n\n", $0
        count = 0
    } else {
        print $0
    }
}
END {
    if (NR > 1) {
        printf "\n%%%%%%%\n%s\n\n"
    }
}' skript2.md > skript3.md

# replace the %%%%% with </section>\n<section>, except the first and the last
sed -e '0,/%%%%/s//<section>/' -e '$s//<\/section>/' -e 's/%%%%/<\/section>\n<section>/g' skript3.md > skript4.md

# convert to html
pandoc -f markdown -t html -o skript5.html skript4.md

rm index.html
cp index-template.html index.html

# inject
ed -s index.html <<EOF
21r skript5.html
wq
EOF

# now, wrap the initial section of the skript in a section
# and it should be ready.