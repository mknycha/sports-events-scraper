# frozen_string_literal: true

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
    '' + wrap_with_th_tag('Name') \
       + wrap_with_th_tag('Score') \
       + wrap_with_th_tag('Time') \
       + wrap_with_th_tag('Link') \
  end

  def html_event_row(event)
    '' + wrap_with_td_tag(event.name) \
       + wrap_with_td_tag(event.score) \
       + wrap_with_td_tag(event.time) \
       + wrap_with_td_tag(event.link) \
  end
end
