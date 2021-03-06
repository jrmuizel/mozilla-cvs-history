# Litmus Makefile

PERL=perl

install: templates
	$(PERL) populatedb.pl
	scripts/minify_js.bash

# precompile all templates with the Template Toolkit
# to speed things up a good bit. 
# This ought to be done in a more "makelike" way, but 
# various difficulties prevent that unless we use a configure 
# script to generate the Makefile, at which point we could have 
# been done already...

%.tmpl: 
	$(PERL) -e " \
		eval('use CGI qw(-no_debug)'); \
		use Litmus::Template;use diagnostics; \
		\$$template = Litmus::Template->create(); \
		\$$template->context()->template('$@'); \
	"

templates: index.tmpl
	$(PERL) -e " \
		use File::Find; \
		find({ wanted => sub { \
			\$$name = \$$File::Find::name; \
			return if (-d \$$name); \
			return if (\$$name =~ /\/CVS\//); \
			return if (\$$name !~ /\.tmpl\$$/); \
			\$$name =~ s/templates\/en\/default\///; \
			if (-M 'templates/en/default/'.\$$name < -M 'data/templates/en/default/'.\$$name \
				|| ! -e 'data/templates/en/default/'.\$$name \
				|| -M 'Litmus/Template.pm' < -M 'data/templates/en/default/'.\$$name) { \
				system("make", "\$$name"); \
			} \
		}, no_chdir => 1 }, 'templates/en/default'); \
	"

# tags: generate ctags style hints for ease of editing
# requires Exuberant Ctags to be installed (http://ctags.sf.net/)
ctags: 
	`which ctags` --excmd=number --tag-relative=no --fields=+a+m+n+S -R `pwd`

tags: ctags

test: 
	$(PERL) runtests.pl

cache: 
	@echo "Deprecated - rebuildCache no longer required";

clean: 
	rm -rf data
	make install
