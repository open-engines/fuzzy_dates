SYSTEM_PACKAGE_PATH = /usr/bin

#
#  publish
#
publish: diagrams ## Publish the diagrams
	@echo $(GIT_REPO_URL) \
	&& cd target/publish \
	&& git init . \
	&& git remote add github ${GIT_REPO_URL} \
	&& git checkout -b gh-pages \
	&& git add . \
	&& git commit -am "Static site deploy" \
	&& git push github gh-pages --force \
	&& cd ../.. || exit

diagrams: memory_usage workflow

target_dir = target/publish

target_dir_charts = $(target_dir)/charts

memory_usage: $(target_dir_charts)/memory-use.svg $(target_dir_charts)/memory-use.png

$(target_dir_charts)/memory-use.svg: memory_profile_pivot.dat $(target_dir_charts)
	@gnuplot -e "input='memory_profile_pivot.dat'" -e "output_format='svg'" performance/memory-usage.gnuplot >$(target_dir_charts)/memory-use.svg

$(target_dir_charts)/memory-use.png: memory_profile_pivot.dat $(target_dir_charts)
	@gnuplot -e "input='memory_profile_pivot.dat'" -e "output_format='png'" performance/memory-usage.gnuplot >$(target_dir_charts)/memory-use.png

$(target_dir_charts):
	@mkdir -p $(target_dir_charts)

memory_profile_pivot.dat: memory_profile.dat
	@performance/memory-usage-pivot.gawk memory_profile.dat > memory_profile_pivot.dat

memory_profile.dat:
	mprof run -C -M -o memory_profile.dat $(PYTHON) performance/demo.py
	sed -i -e 's/CHLD /Children/g' -e 's/MEM/MAIN/g' memory_profile.dat

memory-profile-clean:
	@mprof clean
	@rm memory_profile.dat memory_profile_pivot.dat

workflow: target/publish/workflow.svg  ## Creates the workflow diagrams (TBD)
target/publish/workflow.svg: $(SYSTEM_PACKAGE_PATH)/mvn
	@printf '\e[1;34m%-6s\e[m\n' "Start generation of scalable C4 Diagrams"
	@mvn exec:java@generate-diagrams -f .github/plantuml/
	@printf '\n\e[1;34m%-6s\e[m\n' "Start generation of portable C4 Diagrams"
	@mvn exec:java@generate-diagrams -DoutputType=png -Dlinks=0  -f .github/plantuml/
	@printf '\n\e[1;34m%-6s\e[m\n' "The diagrams has been generated"