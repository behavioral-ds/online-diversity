all: fig1 fig3 fig5 fig6
	
fig1: data/reddit-volume-augmented.csv data/twitter-volume-augmented.csv data/reddit-total-diversity-decline.dat data/twitter-total-diversity-decline.dat
	mkdir -p plots
	Rscript scripts/plot_fig1.R
	
fig2:
	mkdir -p plots
	jupyter nbconvert --to notebook --inplace --execute scripts/plot_fig2.ipynb

fig3: data/reddit-total-diversity-decline.dat data/twitter-total-diversity-decline.dat 
	mkdir -p plots
	Rscript scripts/plot_fig3.R
	
fig4:
	mkdir -p plots
	jupyter nbconvert --to notebook --inplace --execute scripts/plot_fig4.ipynb
	
fig5: data/competitors-merged.dat
	mkdir -p plots
	Rscript scripts/plot_fig5.R

fig6: data/reddit_cohort_analysis.dat data/twitter_cohort_analysis.dat
	mkdir -p plots
	Rscript scripts/plot_fig6.R

fig7:
	mkdir -p plots
	jupyter nbconvert --to notebook --inplace --execute scripts/plot_fig7.ipynb
	
figS3:
	mkdir -p plots
	jupyter nbconvert --to notebook --inplace --execute 
	scripts/plot_figS3.ipynb	
	
clean:
	rm -f data/reddit-volume-augmented.csv data/twitter-volume-augmented.csv data/reddit-total-diversity-decline.dat data/twitter-total-diversity-decline.dat data/competitors-merged.dat data/*.rds table.tex

data/reddit-volume-augmented.csv:
	export OMP_NUM_THREADS=1 ; Rscript scripts/process_compute-reddit-volume.R 
	
data/twitter-volume-augmented.csv:
	export OMP_NUM_THREADS=1 ; Rscript scripts/process_compute-twitter-volume.R
	
data/reddit-total-diversity-decline.dat data/twitter-total-diversity-decline.dat:
	export OMP_NUM_THREADS=1 ; Rscript scripts/process_diversity-decrease.R ;
data/twitter-total-diversity-decline.dat: data/reddit-total-diversity-decline.dat

data/competitors-merged.dat:
	export OMP_NUM_THREADS=1 ; Rscript scripts/process_twelve-functions-competitors.R ;
	
data/reddit_cohort_analysis.dat data/twitter_cohort_analysis.dat:
	export OMP_NUM_THREADS=1 ; Rscript scripts/process_temporal-analysis.R
data/twitter_cohort_analysis.dat: data/reddit_cohort_analysis.dat

