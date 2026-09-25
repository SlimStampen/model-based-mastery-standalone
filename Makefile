.PHONY: demo

# Model Based Mastery demo
demo: scripts/model_based_mastery.Rmd
	Rscript -e "rmarkdown::render('scripts/model_based_mastery.Rmd', output_format = 'all', output_dir = 'output')"