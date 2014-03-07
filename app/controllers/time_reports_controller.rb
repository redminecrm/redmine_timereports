class TimeReportsController < ApplicationController
  unloadable

  Mime::Type.register "application/vnd.ms-excel", :xls
  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  before_filter :authorize_timereport

  helper :sort
  include SortHelper
  helper :issues
  helper :timelog
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper
  include TimeReportsHelper

  def report
    @query = TimeReportsQuery.build_from_params(params, :name => '_')
    @report = RedmineTimeReports::Patches::TimeReport.new(nil, nil, params[:criteria], params[:columns], @query.results_scope)

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.csv  { send_data(report_to_csv(@report), :type => 'text/csv; header=present', :filename => 'timelog.csv') }
      format.xls  { send_data(report_to_xls(@report), :type => 'application/vnd.ms-excel; header=present', :filename => 'timelog.xls', :disposition => 'attachment') }
    end
  end

private

  def authorize_timereport
     deny_access unless RedmineTimeReports.allow_reports?
  end

end
