PARADOCS=./paradocs/dist/build/paradocs/paradocs

gh-pages/index.html: index.pdoc
	mkdir -p $(shell dirname $@)
	$(PARADOCS) $^ > $@

gh-pages/shumatsu-lambda/index.html: shumatsu-lambda/index.pdoc
	mkdir -p $(shell dirname $@)
	$(PARADOCS) $^ > $@

gh-pages/kansu-lt/index.html: kansu-lt/index.pdoc
	mkdir -p $(shell dirname $@)
	$(PARADOCS) $^ > $@
