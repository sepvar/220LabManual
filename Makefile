# Lab Manual and Set-up Instructions

default: 
	@echo "make -n ... to display commands with running"
	@echo "make -s ... to not display commands when running them"
	@echo "Choices: setup-h, setup-l, 220-h, 220-l, images, list (prints copy-paste select image creation), counterr, toperr, typeerr, allerr"
	@echo "make all will make all html, all latex, and images"
	@echo -e "Suggested process: \nmake 220-p\nmake labpdf (fix with PDFsam as instructed)\nmake checksize (then if different, continue)\nmake fixsize\nREPEAT ONCE"

git: 
	git diff-index --stat master

view: 
	@echo "This option is DISCONTINUED... it no longer functions for some reason."
	@echo "/c/Program\ Files/Mozilla\ Firefox/firefox.exe ${LABSETUP}/TMC-lab-setup.html anything-lab.html > /dev/null &"

${LABSETUP}/src/mathbook-setup-latex.xsl: 
	cd ${LABSETUP} ; git diff-index --name-only master | grep mathbook-setup-latex.xsl && git diff-index --stat master 

${LABSETUP}/src/mathbook-setup-html.xsl: 
	cd ${LABSETUP} ; git diff-index --name-only master | grep mathbook-setup-html.xsl && git diff-index --stat master

${LABSETUP}/src/Lab-setup.ptx:
	cd ${LABSETUP} ; git diff-index --name-only master | grep Lab-setup.ptx && git diff-index --stat master

src/mathbook-lab-latex.xsl: 
	git diff-index --name-only master | grep mathbook-lab-latex.xsl && git diff-index --stat master 

src/mathbook-lab-html.xsl: 
	git diff-index --name-only master | grep mathbook-lab-html.xsl && git diff-index --stat master

src/220-Lab-Manual.ptx:
	git diff-index --name-only master | grep 220-Lab-Manual.ptx && git diff-index --stat master


${MATHBOOK}/user/mathbook-setup-latex.xsl: ${LABSETUP}/src/mathbook-setup-latex.xsl
	cp ${LABSETUP}/src/mathbook-setup-latex.xsl ${MATHBOOK}/user/

${MATHBOOK}/user/mathbook-setup-html.xsl: ${LABSETUP}/src/mathbook-setup-html.xsl
	cp ${LABSETUP}/src/mathbook-setup-html.xsl ${MATHBOOK}/user/

${MATHBOOK}/user/mathbook-lab-latex.xsl: src/mathbook-lab-latex.xsl
	cp src/mathbook-lab-latex.xsl ${MATHBOOK}/user/

${MATHBOOK}/user/mathbook-lab-html.xsl: src/mathbook-lab-html.xsl
	cp src/mathbook-lab-html.xsl ${MATHBOOK}/user/

setup-h: ${MATHBOOK}/user/mathbook-setup-html.xsl ${LABSETUP}/src/Lab-setup.ptx 
	cd ${LABSETUP} ; xsltproc --xinclude ${MATHBOOK}/user/mathbook-setup-html.xsl src/Lab-setup.ptx

setup-l: ${MATHBOOK}/user/mathbook-setup-latex.xsl Lab-setup.ptx 
	cd ${LABSETUP} ; xsltproc --xinclude ${MATHBOOK}/user/mathbook-setup-latex.xsl src/Lab-setup.ptx

setup-p: setup-l
	pdflatex TMC-lab-setup.tex

setup: setup-h setup-p


220-h: ${MATHBOOK}/user/mathbook-lab-html.xsl src/220-Lab-Manual.ptx
	xsltproc --xinclude ${MATHBOOK}/user/mathbook-lab-html.xsl src/220-Lab-Manual.ptx
	@echo ""

anything-lab.tex: ${MATHBOOK}/user/mathbook-lab-latex.xsl src/220-Lab-Manual.ptx
	xsltproc --xinclude ${MATHBOOK}/user/mathbook-lab-latex.xsl src/220-Lab-Manual.ptx
	sed -i.sedfix -f scripts/220-Lab-Manual.sed anything-lab.tex

220-l: anything-lab.tex

anything-lab.pdf: anything-lab.tex
	pdflatex anything-lab.tex && pdflatex anything-lab.tex || pdflatex anything-lab.tex

220-p: anything-lab.pdf 

220: 220-h 220-p checksize

html: setup-h 220-h

latex: setup-l 220-l

pdf: 220-p setup-p

checksize:
	@echo "Building scripts/list.one and scripts/list.two..."
	@echo "#!/bin/sh" > scripts/list.one
	@echo "#!/bin/sh" > scripts/list.two
	@grep "PDF version" src/220-Lab-Manual.ptx | sed 's#.*\">\(.*\)\.pdf (\([0-9][0-9]*\) kB.*#echo "echo -e \\\"claim: \2\\\\tactual:\\\" \\\\`expr `stat --printf=%s \1.pdf` / 1000\\\\`\\\\\t\1" >> scripts/list.two#g' >> scripts/list.one 
	scripts/list.one 
	scripts/list.two
	@echo -e "If these numbers do not match, you might want to:\nmake fixsize"

fixsize:
	@echo "Building scripts/step.one and scripts/step.two..."
	@echo "#!/bin/sh" > scripts/step.one
	@echo "#!/bin/sh" > scripts/step.two
	@grep "PDF version" src/220-Lab-Manual.ptx | sed 's#.*\">\(.*\)\.pdf (\([0-9][0-9]*\) kB.*#echo "echo \\"s^\1.pdf (\2 kB)^\1.pdf (\\\\`expr `stat --printf=%s \1.pdf` / 1000\\\\` kB)^g\\"" >> scripts/step.two#g' >> scripts/step.one 
	scripts/step.one 
	scripts/step.two > scripts/step.sed
	sed -i.size -f scripts/step.sed src/220-Lab-Manual.ptx
	$(MAKE) checksize --no-print-directory

scripts/buildpdfs: anything-lab.pdf
	@echo "Creating scripts/scripttolistbyname... (print at end)"
	@echo "#!/bin/sh" > scripts/scripttolistbyname
	@grep "chapter" anything-lab.toc | \
		sed -n 'N;l;D' | \
		sed ':x ; $$!N ; s/\\\\\n// ; tx ; P ; D' | \
		grep -v "chapter\*" | \
		sed 's/\(.*\)\$$/\1/g' | \
		sed 's/.*{.*}{.*{.*}.\{3\}\(.*\)}{\([0-9][0-9]*\)}{\(.*\)}.*{.*}{.*{.*}.*}{\([0-9][0-9]*\)}{.*}/grep \"\1\\}\\\\\\\\\\\\\\\\label\" anything-lab.tex \| sed \x22s#.\*label{\\\\(.\*\\\\)}#\3: `expr \2 + 12`..`expr \4 + 11`\\\\t\\\\1#g\x22 \| sed \x27s#c-##g\x27/g' \
		>> scripts/scripttolistbyname
	@echo "Creating scripts/buildscript..."
	@echo "#!/bin/sh" > scripts/buildscript
	@grep "chapter" anything-lab.toc | \
		sed -n 'N;l;D' | \
		sed ':x ; $$!N ; s/\\\\\n// ; tx ; P ; D' | \
		grep -v "chapter\*" | \
		sed 's/\(.*\)\$$/\1/g' | \
		sed 's/.*{.*}{.*{.*}.\{3\}\(.*\)}{\([0-9][0-9]*\)}{\(.*\)}.*{.*}{.*{.*}.*}{\([0-9][0-9]*\)}{.*}/grep \"\1\\}\\\\\\\\\\\\\\\\label\" anything-lab.tex \| sed \x22s#c-##g\x22 \| sed \x22s#.\*label{\\\\(.\*\\\\)}#pdfseparate -f `expr \2 + 12` -l `expr \4 + 11` anything-lab.pdf \\\\1.\%d.pdf ; rm \\\\1_big.pdf \\\\1.pdf ; pdfunite \\\\1.*.pdf \\\\1_big.pdf ; rm \\\\1.*.pdf ; ps2pdf \\\\1_big.pdf \\\\1.pdf#g\x22/g' \
		>> scripts/buildscript
	@echo "#!/bin/sh" > scripts/buildpdfs
	@echo "Using scripts/buildscript to create scripts/buildpdfs..."
	scripts/buildscript >> scripts/buildpdfs
	@echo "Running scripts/buildpdfs to create the lab pdfs."
	scripts/buildpdfs 2> /dev/null
	scripts/scripttolistbyname
	@echo "You need to use PDFsam to fix the labs with pictures: measurement and StDev."
	@echo -e "I am going to run PDFsam, you should do this:\nextract pages listed\nmv PDFsam_anything-lab.pdf measurement.pdf\nextract pages for StDev\nmv PDFsam_anything-lab.pdf StDev.pdf\nmake checksize\nmake fixsize\nscripts/scripttolistbyname"
	@/c/Program\ Files\ \(x86\)/PDFsam\ Basic/bin/pdfsam.sh -e ./anything-lab.pdf &

# $(MAKE) checksize --no-print-directory

labpdf: scripts/buildpdfs

images: src/220-Lab-Manual.ptx ${LABSETUP}/src/Lab-setup.ptx
	${MATHBOOK}/script/mbx -v -c latex-image -f svg -d images ${DEE}/src/220-Lab-Manual.ptx
#	${MATHBOOK}/script/mbx -v -c latex-image -r [specific image reference] -f svg -d images ${DEE}/src/220-Lab-Manual.ptx
	${MATHBOOK}/script/mbx -v -c latex-image -f svg -d images ${LABSETUP}/src/Lab-setup.ptx


# To list the images in the ptx and print a line that will check to see if that image exists and (if not) try to create the image...

list: src/220-Lab-Manual.ptx ${LABSETUP}/src/Lab-setup.ptx
	cat ${LABSETUP}/src/Lab-setup.ptx | \
		sed 's/^ *<image/<image/g' | \
		grep '<image' | grep -v "images" | \
		sed 's/ width=.*>/>/g' | \
		sed 's+^.*ptx:id=\"\(.*\)\">+ls images/\1.svg || C:/Users/tensen/Desktop/Book/mathbook/script/mbx \-v \-c latex-image \-r \1 \-f svg \-d images ${LABSETUP}/Lab-setup.ptx+g'
	@echo "*************************"
	cat src/220-Lab-Manual.ptx | \
		sed 's/^ *<image/<image/g' | \
		grep '<image' | grep -v "images" | \
		sed 's/ width=.*>/>/g' | \
		sed 's+^.*ptx:id=\"\(.*\)\">+ls images/\1.svg || C:/Users/tensen/Desktop/Book/mathbook/script/mbx \-v \-c latex-image \-r \1 \-f svg \-d images ${PHY220L}/src/220-Lab-Manual.ptx+g'

counterr: ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx  ${LABSETUP}/src/Lab-setup.ptx
	@echo `java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng ${LABSETUP}/src/Lab-setup.ptx | wc -l`" errors"
	@echo `java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx | wc -l`" errors"

toperr: ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx  ${LABSETUP}/src/Lab-setup.ptx
	java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng ${LABSETUP}/src/Lab-setup.ptx | head -5
	@echo "*************************"
	java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx | head -5

typeerr: ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx  ${LABSETUP}/src/Lab-setup.ptx
	java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng ${LABSETUP}/src/Lab-setup.ptx | \
		sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\): error: element "\([a-zA-Z][a-zA-Z]*\)".*/\3 line \1:\2/g' | \
		sort -k1
	@echo "*************************"
	java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx | \
		sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\): error: element "\([a-zA-Z][a-zA-Z]*\)".*/\3 line \1:\2/g' | \
		sort -k1

# To find the errors on "todo"  (must change in two places)                                                vvvv                                                 vvvv
# 	java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx | grep ": element \"todo" | sed 's/.*:\([0-9][0-9]*\):\([0-9][0-9]*\):.*/todo line \1:\2/g'
#                                                                                                          ^^^^                                                 ^^^^

allerr: ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx  ${LABSETUP}/src/Lab-setup.ptx
	java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng ${LABSETUP}/src/Lab-setup.ptx | \
		sort -k4  
	@echo "*************************"
	java -jar ${MATHBOOK}/../jing-trang/build/jing.jar ${MATHBOOK}/schema/pretext.rng src/220-Lab-Manual.ptx | \
                grep -v `grep -n "known tag abuse 1" src/220-Lab-Manual.ptx | sed 's/:.*//g'` | \
		sort -k4  

all: setup-h 220-h setup-l 220-l images
