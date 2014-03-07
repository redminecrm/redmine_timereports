module TimeReportsHelper
  require 'spreadsheet'
  # include TimelogHelper

  def report_to_xls(report)
    xls = []
    decimal_separator = l(:general_csv_decimal_separator)
    # Column headers
    headers = report.criteria.collect {|criteria| l(report.available_criteria[criteria][:label]) }
    headers += report.periods
    headers << l(:label_total_time)
    xls << headers.collect {|c| Redmine::CodesetUtil.from_utf8(
                                  c.to_s,
                                  l(:general_csv_encoding) ) }
    # Content
    report_criteria_to_csv(xls, report.available_criteria, report.columns, report.criteria, report.periods, report.hours)
    # Total row
    str_total = Redmine::CodesetUtil.from_utf8(l(:label_total_time), l(:general_csv_encoding))
    row = [ str_total ] + [''] * (report.criteria.size - 1)
    total = 0
    report.periods.each do |period|
      sum = sum_hours(select_hours(report.hours, report.columns, period.to_s))
      total += sum
      row << (sum > 0 ? ("%.2f" % sum).gsub('.',decimal_separator) : '')
    end
    row << ("%.2f" % total).gsub('.',decimal_separator)
    xls << row

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    xls.each_with_index do |row, index|
      xls_row = sheet.row(index)
      xls_row.replace row
    end

    xls_stream = StringIO.new('')
    book.write(xls_stream)

    return xls_stream.string
  end

end
