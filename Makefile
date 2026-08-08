PORT ?= 3000

.PHONY: setup start

setup:
	cp .env.example .env
	bundle install
	bin/rails assets:precompile
	bin/rails db:prepare

start:
	bin/rails server -b 0.0.0.0 -p $(PORT)