require 'redmine_timereports'

Redmine::Plugin.register :redmine_timereports do
  name 'Redmine Timereports plugin'
  author 'RedmineCRM'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'mailto:support@redminecrm.com'
  author_url 'http://redminecrm.com'

  settings :default => {
    'access_group' => nil
  }, :partial => 'settings/time_reports'

  menu :top_menu, :timereports,
                          {:controller => 'time_reports', :action => 'report'},
                          :caption => :label_timereport_plural,
                          :if => RedmineTimeReports.allow_reports?

end
