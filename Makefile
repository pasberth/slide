PARADOCS=./paradocs/dist/build/paradocs/paradocs

gh-pages/shumatsu-lambda/index.html: shumatsu-lambda/index.pdoc
	mkdir -p $(shell dirname $@)
	$(PARADOCS) $^ > $@