
require File.expand_path('../lib/rwf_application_helper_patch', __FILE__)

Redmine::Plugin.register :redmine_wiki_formatting do
  name 'Redmine wiki formatting plugin'
  author 'Akinori Iwasaki'
  description 'This is a redmine plugin that allows you to change the wiki format.'
  version '0.1.0'
  url 'https://github.com/aki360P/redmine_wiki_formatting'
  
end