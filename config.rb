require "node.rb"
require "better_errors"

set :protect_from_csrf, true
set :layout, :default
config.encoding = 'utf-8'

activate :directory_indexes
activate :livereload, host: 'localhost'

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

helpers do
  def course_files(course)
    folders = folder_list(course.children)

    file_heading = course.files.any? ? content_tag(:h2, "Filer") : ''
    files = file_heading + file_list(course.files)
    (folders + files)
  end

  def folder_list(children, l = 2)
    return '' if children.nil?
    children.collect do |child|
      heading = content_tag("h#{l}", child.name.humanize)

      list = file_list(child.files, "#{child.path}/")

      children = folder_list(child.children, [l + 1, 6].min)
      heading + list + children
    end.join('').html_safe
  end

  def file_list(files, path = '')
    return '' if files.nil?
    files.sort.collect do |file|
      content_tag(:li, class: 'list-unstyled') do
        file_path = "#{path}#{file}"
        link_to file.gsub(".html", ''), file_path, relative: true
      end
    end.join('').html_safe
  end

  def course_tree
    root_node = Node.new('courses', nil)

    sitemap.resources.select { |r| r.url.include? "courses" }.each do |path|
      splits = path.path.split('/').drop(1)
      root_node.add_resource(*splits)
    end
    root_node
  end

  def course_readme(course)
    if course.files.include?("readme.html")
      partial "/courses/#{course.name}/readme.md"
    elsif course.files.include?("README.html")
      partial "/courses/#{course.name}/README.md"
    elsif course.files.include?("Readme.html")
      partial "/courses/#{course.name}/Readme.md"
    end
  end

  def breadcrumbs
    path_split = current_page.path.split('/')
    return '' if path_split.length <= 2
    course_index_offset = (path_split.length == 3 && path_split.last.include?('index')) ? 1 : 0
    root_path   = '../' * (path_split.length - course_index_offset)
    course_path = '../' * (path_split.length - course_index_offset - 2)

    path_split[0] = link_to("Kurser", root_path, class: 'nav-link')
    path_split[1] = link_to(path_split[1], course_path, class: 'nav-link')
    path_split.join(" / ").gsub(".html", '').html_safe
  end
end

ready do
  course_tree.children.each do |course|
    proxy "/courses/#{course.name}/index.html", "course.html", locals: { course: course }
  end
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  activate :gzip

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

# Deploy settings
activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
  # Optional Settings
  # deploy.remote   = 'custom-url' # remote name or git url, default: origin
  # deploy.branch   = 'custom-branch' # default: gh-pages
  # deploy.strategy = :submodule      # commit strategy: can be :force_push or :submodule, default: :force_push
  # deploy.commit_message = 'custom-message'      # commit message (can be empty), default: Automated commit at `timestamp` by middleman-deploy `version`
end
