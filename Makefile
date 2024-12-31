HUGO_DIR = tyk-docs
PUBLIC = public
LOCAL_RESOURCES = local-resources

DOCKER_TEST = tyk-docs-test
DOCKER_TEST_PORT = 8080

LOCAL_PORT = 8000

hugo:
	rm -rf $(HUGO_DIR)/public
	cd $(HUGO_DIR) && hugo

gen-menu: hugo
	python3 scripts/menu_generator.py data-bank.csv pages-list.csv tyk-docs/public/urlcheck.json

build: hugo
	rm -rf $(PUBLIC)
	mv $(HUGO_DIR)/public $(PUBLIC) && cp -r $(LOCAL_RESOURCES) $(PUBLIC)

run: build
	cd $(PUBLIC) && python3 -m http.server $(LOCAL_PORT) --bind 0.0.0.0

test:
	docker rm -f $(DOCKER_TEST)
	docker rmi -f $(DOCKER_TEST)
	docker build -t $(DOCKER_TEST) .
	docker run --name $(DOCKER_TEST) -p $(DOCKER_TEST_PORT):80 -d $(DOCKER_TEST)

