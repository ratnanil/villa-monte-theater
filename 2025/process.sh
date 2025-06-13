# Download a copy of the reveal.js repo into this years folder
# e.g. into ./2024/revealjs/

# make a copy of revealjs' index.html
cp revealjs/index.html index.html
# adjust the paths so that it works on this folder level
perl -i -p -e 's/(href|src)="/$1="revealjs\//g;' index.html 


# Now, work on the theater script:

# convert docx to markdown
pandoc -f docx -t markdown -o skript1.md Skript.docx

awk '{gsub(/([[:space:]])\*\*/, "\\1\n\n**"); print}' skript1.md > skript1b.md


# remove single linebreaks
awk 'BEGIN{ORS=RS="\n\n"} {gsub("\n", " "); print}' skript1b.md > skript2.md

# add +++++++ if the cummulative count of characters exceeds 150
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

# replace the +++++++ with </section>\n<section>, except the first and the last
sed -e '0,/+++++++/s//<section>/' -e '$s//<\/section>/' -e 's/+++++++/<\/section>\n<section>/g' skript3.md > skript4.md

# convert to html
pandoc -f markdown -t html -o skript5.html skript4.md



# in index.html, delete the two example slides. Then inject skript5.html into index using the
# command below. Make sure line 20 is the correct location
ed -s index.html <<EOF
20r skript5.html
wq
EOF

# now, do some manual cleaning and optionally style all "strong" tags (these are usually the)
# persons speaking, e.g. with the following css:
# strong{
#     color: #FFA500;
# }

# also, enable the search plugin (revealjs/plugin/search/search.js), by adding this path and 
# enabling ReveaSearch