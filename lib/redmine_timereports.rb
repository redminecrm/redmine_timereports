require_dependency 'redmine_timereports/patches/time_report_patch'

module RedmineTimeReports
  def self.allow_reports?
     return true if User.current.admin?
     access_group = Group.where(:id => Setting.respond_to?(:plugin_redmine_timereports) ? Setting.plugin_redmine_timereports['access_group'] : nil).first
     User.current.groups.include?(access_group)
  end
end