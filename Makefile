gen-menu: hugo
	python3 scripts/menu_generator.py data-bank.csv pages-list.csv tyk-docs/public/urlcheck.json

hugo:
	rm -rf public && rm -rf tyk-docs/public
	cd tyk-docs && hugo --theme=tykio
	mv tyk-docs/public public && cp -r local-resources public

test:
	docker rm -f tyk-docs-test
	docker rmi -f tyk-docs-test
	docker build -t tyk-docs-test .
	docker run --name tyk-docs-test -p 8080:80 -d tyk-docs-test

