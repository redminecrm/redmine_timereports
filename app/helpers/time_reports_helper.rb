module TimeReportsHelper

  def report_criteria_to_xls(xls, available_criteria, columns, criteria, periods, hours, level=0)
    require 'spreadsheet'

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet

    idx = 0
    row = sheet.row(idx)
    row.replace headers

    contacts.each do |contact|
      idx += 1
      row = sheet.row(idx)
      fields = [contact.id,
                  contact.is_company ? 1 : 0,
                  contact.first_name,
                  contact.middle_name,
                  contact.last_name,
                  contact.job_title,
                  contact.company,
                  contact.phone,
                  contact.email,
                  contact.address.to_s.gsub("\r\n"," ").gsub("\n", ' '),
                  contact.city,
                  contact.postcode,
                  contact.region,
                  contact.country,
                  contact.skype_name,
                  contact.website,
                  format_date(contact.birthday),
                  contact.tag_list.to_s,
                  contact.background.to_s.gsub("\r\n"," ").gsub("\n", ' ')
                  ]
      contact.custom_field_values.each {|custom_value| fields << RedmineContacts::CSVUtils.csv_custom_value(custom_value) }
      row.replace fields
    end

    xls_stream = StringIO.new('')
    book.write(xls_stream)

    return xls_stream.string


    decimal_separator = l(:general_xls_decimal_separator)
    hours.collect {|h| h[criteria[level]].to_s}.uniq.each do |value|
      idx += 1
      hours_for_value = select_hours(hours, criteria[level], value)
      next if hours_for_value.empty?
      row = sheet.row(idx)
      fields = []
      fields = [''] * level

      fields << Redmine::CodesetUtil.from_utf8(
                        format_criteria_value(available_criteria[criteria[level]], value).to_s,
                        l(:general_xls_encoding) )
      fields += [''] * (criteria.length - level - 1)
      total = 0
      periods.each do |period|
        sum = sum_hours(select_hours(hours_for_value, columns, period.to_s))
        total += sum
        fields << (sum > 0 ? ("%.2f" % sum).gsub('.',decimal_separator) : '')
      end
      row << ("%.2f" % total).gsub('.',decimal_separator)
      xls << row
      if criteria.length > level + 1
        report_criteria_to_xls(xls, available_criteria, columns, criteria, periods, hours_for_value, level + 1)
      end
    end
  end

end
