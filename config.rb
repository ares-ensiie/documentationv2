# HACK HAML 4
Haml::Filters.remove_filter('Markdown')
Haml::Filters.register_tilt_filter('Markdown', template_class: Tilt::RedcarpetTemplate::Redcarpet2)
# END HACK

set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'

activate :livereload
activate :directory_indexes

configure :build do
  activate :minify_css
  activate :minify_javascript
end

activate :deploy do |deploy|
  deploy.method = :git
end

activate :syntax

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true
