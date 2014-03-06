class TimeReportsQuery < TimeEntryQuery
  unloadable

  def initialize_available_filters
    add_available_filter "spent_on", :type => :date_past

    users_values = []
    users_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    users_values += User.logged.active.sorted.collect{|s| [s.name, s.id.to_s] }
    add_available_filter("user_id",
      :type => :list_optional, :values => users_values
    ) unless users_values.empty?

    group_values = Group.all.collect {|g| [g.name, g.id.to_s] }
    add_available_filter("member_of_group",
      :type => :list_optional, :values => group_values, :name => l(:label_timereport_group)
    ) unless group_values.empty?

    activities = TimeEntryActivity.shared.active
    add_available_filter("activity_id",
      :type => :list, :values => activities.map {|a| [a.name, a.id.to_s]}
    ) unless activities.empty?

    add_available_filter "comments", :type => :text
    add_available_filter "hours", :type => :float

    add_custom_fields_filters(TimeEntryCustomField)
    add_associations_custom_fields_filters :project, :issue, :user
  end

  def sql_for_member_of_group_field(field, operator, value)
    if operator == '*' # Any group
      groups = Group.all
      operator = '=' # Override the operator since we want to find by assigned_to
    elsif operator == "!*"
      groups = Group.all
      operator = '!' # Override the operator since we want to find by assigned_to
    else
      groups = Group.where(:id => value).all
    end
    groups ||= []

    members_of_groups = groups.inject([]) {|user_ids, group|
      user_ids + group.user_ids + [group.id]
    }.uniq.compact.sort.collect(&:to_s)

    '(' + sql_for_field("user_id", operator, members_of_groups, TimeEntry.table_name, "user_id", false) + ')'
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

    TimeEntry.
      where(statement).
      order(order_option).
      joins(joins_for_order_statement(order_option.join(','))).
      includes(:activity)
  end

end