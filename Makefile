setup:
	bundle install
	bin/rails assets:precompile
	bin/rails db:prepare

start:
	bin/rails server -p 3000