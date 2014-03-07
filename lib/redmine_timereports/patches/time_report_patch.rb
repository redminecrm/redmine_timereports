module RedmineTimeReports
  module Patches
    module TimeReportPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:include, Redmine::I18n)

        base.class_eval do
          alias_method_chain :load_available_criteria, :time_reports
        end
      end

      module InstanceMethods
        def load_available_criteria_with_time_reports
          @available_criteria = load_available_criteria_without_time_reports
          custom_fields = UserCustomField.all

          custom_fields.select {|cf| %w(list bool).include?(cf.field_format) && !cf.multiple?}.each do |cf|
            @available_criteria["cf_#{cf.id}"] = {:sql => cf.group_statement,
                                                   :joins => cf.join_for_order_statement,
                                                   :format => cf.field_format,
                                                   :custom_field => cf,
                                                   :label => l(:label_user) + ': ' + cf.name}
          end

          @available_criteria
        end
      end
    end
  end
end

unless Redmine::Helpers::TimeReport.included_modules.include?(RedmineTimeReports::Patches::TimeReportPatch)
  Redmine::Helpers::TimeReport.send(:include, RedmineTimeReports::Patches::TimeReportPatch)
end