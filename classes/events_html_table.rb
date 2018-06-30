class EventsHtmlTable
  TABLE_OPENING_TAG = '<table>'
  TABLE_CLOSING_TAG = '</table>'

  def initialize
    @data = []
    @data.push(html_headers_row)
  end

  def add_event(event)
    @data.push(html_event_row(event))
  end

  def to_s
    result = @data.clone
    result.insert(0, TABLE_OPENING_TAG)
    result.insert(-1, TABLE_OPENING_TAG)
    result.join
  end

  private

  def wrap_with_th_tag(string)
    "<th>#{string}</th>"
  end

  def wrap_with_td_tag(string)
    "<td>#{string}</td>"
  end

  def html_headers_row
    html_row = ''
    html_row << wrap_with_th_tag('Name')
    html_row << wrap_with_th_tag('Score')
    html_row << wrap_with_th_tag('Time')
    html_row << wrap_with_th_tag('Link')
    html_row
  end

  def html_event_row(event)
    html_row = ''
    html_row << wrap_with_td_tag(event.name)
    html_row << wrap_with_td_tag(event.score)
    html_row << wrap_with_td_tag(event.time)
    html_row << wrap_with_td_tag(event.link)
    html_row
  end
end
