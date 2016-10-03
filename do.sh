#! /bin/bash

MAIN="src/main.bib"
CLEANED="src/.main.bib"

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc '--select{@InProceedings}' $MAIN > $CLEANED

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc '--select{@InProceedings}' $MAIN > .papers
bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc '--select{keywords "workshop"}' .papers > .workshops
bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc '--select{@Article}' $MAIN > .journals
bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc '--select{@TechReport}' $MAIN > .reports
bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc '--select{@Unpublished}' $MAIN > .talks
bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc '--select{@PhdThesis}' $MAIN > .dissertations

rm README.md

echo '# Publications' >> README.md
echo "  * $(grep '^@' .papers | wc -l | tr -d '[:space:]') conference papers" >> README.md
echo "  * $(grep '^@' .workshops | wc -l | tr -d '[:space:]') workshop papers" >> README.md
echo "  * $(grep '^@' .journals | wc -l | tr -d '[:space:]') journal papers" >> README.md
echo "  * $(grep '^@' .reports | wc -l | tr -d '[:space:]') technical reports" >> README.md
echo "  * $(grep '^@' .talks | wc -l | tr -d '[:space:]') talks" >> README.md
echo "  * $(grep '^@' .dissertations | wc -l | tr -d '[:space:]') dissertations" >> README.md
echo "" >> README.md
echo "Updated on $(date)" >> README.md

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc -r bibtool/papers.rsc '--select.non{keywords "workshop"}' .papers > papers.bib
rm .papers

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc -r bibtool/journals.rsc .journals > journals.bib
rm .journals

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc -r bibtool/reports.rsc .reports > reports.bib
rm .reports

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc -r bibtool/workshops.rsc .workshops > workshops.bib
rm .workshops

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc -r bibtool/talks.rsc .talks > talks.bib
rm .talks

bibtool -r bibtool/sort_fld.rsc -r bibtool/main.rsc -r bibtool/dissertations.rsc .dissertations > dissertations.bib
rm .dissertations

echo '[INFO] Checking for missing files'
cat *.bib | grep file | grep -oE '\{[^}]+\}' | tr -d '[{}]' | \
  while read f
  do
    if [[ ! -e "$f" ]]
    then
      echo '-------------------------------------------------------------------------------'
      echo "[ERROR] File not found: $f"
      echo '-------------------------------------------------------------------------------'
      grep -B 10 $f *.bib
      echo '-------------------------------------------------------------------------------'
    fi
  done

echo '[INFO] Checking for unused files'
find files -type f -iname '*.pdf' | \
  while read f
  do
    grep -q $f *.bib || echo "[WARNING] $f not used"
  done
