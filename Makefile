all: init run
	

init:
	Rscript -e "renv::restore()"
	
run:
	Rscript -e "targets::tar_make()"

clean:
	rm -rf _targets tmp output .Rhistory
	
extraclean: clean
	rm -rf renv/library renv/local renv/cellar renv/lock renv/python renv/sandbox renv/staging
	