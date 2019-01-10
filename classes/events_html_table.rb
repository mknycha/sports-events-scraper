# frozen_string_literal: true

class EventsHtmlTable
  TABLE_OPENING_TAG = '<table>'.freeze
  TABLE_CLOSING_TAG = '</table>'.freeze

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
    result.insert(-1, TABLE_CLOSING_TAG)
    result.join
  end

  def empty?
    @data.length < 2
  end

  private

  def wrap_with_th_tag(string)
    "<th>#{string}</th>"
  end

  def wrap_with_td_tag(string)
    "<td>#{string}</td>"
  end

  def wrap_with_tr_tag(string)
    "<tr>#{string}</tr>"
  end

  def html_headers_row
    wrap_with_tr_tag(
      [
        wrap_with_th_tag('Name'),
        wrap_with_th_tag('Score'),
        wrap_with_th_tag('Time'),
        wrap_with_th_tag('Model score'),
        wrap_with_th_tag('Link')
      ].join
    )
  end

  def html_event_row(event)
    wrap_with_tr_tag(
      [
        wrap_with_td_tag(event.name),
        wrap_with_td_tag(event.score),
        wrap_with_td_tag(event.time),
        wrap_with_td_tag(model_score(event)),
        wrap_with_td_tag(event.link_to_stats)
      ].join
    )
  end

  def model_score(event)
    EventConditionChecker.event_model_value(event)
  end
end
