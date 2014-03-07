module RedmineTimeReports
  module Patches
    class TimeReport < Redmine::Helpers::TimeReport
      include Redmine::I18n

      def load_available_criteria
        @available_criteria = { 'project' => {:sql => "#{TimeEntry.table_name}.project_id",
                                              :klass => Project,
                                              :label => :label_project},
                                 'status' => {:sql => "#{Issue.table_name}.status_id",
                                              :klass => IssueStatus,
                                              :label => :field_status},
                                 'version' => {:sql => "#{Issue.table_name}.fixed_version_id",
                                              :klass => Version,
                                              :label => :label_version},
                                 'category' => {:sql => "#{Issue.table_name}.category_id",
                                                :klass => IssueCategory,
                                                :label => :field_category},
                                 'user' => {:sql => "#{TimeEntry.table_name}.user_id",
                                             :klass => User,
                                             :label => :label_user},
                                 'tracker' => {:sql => "#{Issue.table_name}.tracker_id",
                                              :klass => Tracker,
                                              :label => :label_tracker},
                                 'activity' => {:sql => "#{TimeEntry.table_name}.activity_id",
                                               :klass => TimeEntryActivity,
                                               :label => :label_activity},
                                 'issue' => {:sql => "#{TimeEntry.table_name}.issue_id",
                                             :klass => Issue,
                                             :label => :label_issue}
                               }

        # Add time entry custom fields
        custom_fields = TimeEntryCustomField.all
        # Add project custom fields
        custom_fields += ProjectCustomField.all
        # Add issue custom fields
        custom_fields += (@project.nil? ? IssueCustomField.for_all : @project.all_issue_custom_fields)
        # Add time entry activity custom fields
        custom_fields += TimeEntryActivityCustomField.all
        custom_fields += UserCustomField.all

        # Add list and boolean custom fields as available criteria
        custom_fields.select {|cf| %w(list bool).include? cf.field_format }.each do |cf|
          @available_criteria["cf_#{cf.id}"] = {:sql => cf.group_statement,
                                                 :joins => cf.join_for_order_statement,
                                                 :format => cf.field_format,
                                                 :custom_field => cf,
                                                 :label => l("label_attribute_of_#{cf.class.customized_class.name.underscore}", :name => cf.name)}
        end

        @available_criteria
      end

    end
  end
end

# unless Redmine::Helpers::TimeReport.included_modules.include?(RedmineTimeReports::Patches::TimeReportPatch)
#   Redmine::Helpers::TimeReport.send(:include, RedmineTimeReports::Patches::TimeReportPatch)
# end