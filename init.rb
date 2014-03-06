Redmine::Plugin.register :redmine_timereports do
  name 'Redmine Timereports plugin'
  author 'RedmineCRM'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'mailto:support@redminecrm.com'
  author_url 'http://redminecrm.com'

  menu :top_menu, :timereports,
                          {:controller => 'timereports', :action => 'report'},
                          :caption => :label_timereport_plural

end
