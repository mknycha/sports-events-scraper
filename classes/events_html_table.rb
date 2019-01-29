# frozen_string_literal: true

class EventsHtmlTable
  def initialize
    @data = []
    @data.push(html_headers_row)
  end

  def add_event(event)
    @data.push(html_event_row(event))
  end

  def to_s
    wrap_with_tag(:table, @data.clone.join)
  end

  def empty?
    @data.length < 2
  end

  private

  def wrap_with_tag(html_tag, content)
    "<#{html_tag}>#{content}</#{html_tag}>"
  end

  def html_headers_row
    wrap_with_tag(:tr, [
      wrap_with_tag(:th, 'Name'),
      wrap_with_tag(:th, 'Score'),
      wrap_with_tag(:th, 'Time'),
      wrap_with_tag(:th, 'Model score'),
      wrap_with_tag(:th, 'Link')
    ].join)
  end

  def html_event_row(event)
    wrap_with_tag(:tr, [
      wrap_with_tag(:td, event.name),
      wrap_with_tag(:td, event.score),
      wrap_with_tag(:td, event.time),
      wrap_with_tag(:td, formatted_model_score(event)),
      wrap_with_tag(:td, event.link)
    ].join)
  end

  def formatted_model_score(event)
    format('%0.2f', EventConditionChecker.event_model_value(event))
  end
end
