module Zaiku
  module ApplicationHelper
    def link_to_modal(name = nil, options = {}, html_options = {}, &block)
    if options == {} && !name.is_a?(String) # name was omitted
      options = name
      name = nil
    end
    html_options[:remote] = true
    html_options[:url] = url_for(options)
    html_options[:class] = html_options[:class].to_s + ' link'
    if block
      tag.span capture(&block), html_options
    else
      tag.span name, html_options
    end
  end

  def more_menu(&block)
    tag.div(class: 'more-menu', 'data-controller': 'expand') do
      tag.div(class: 'more-menu__trigger', 'data-action': 'click->expand#toggle click@window->expand#hide') +
        tag.div(class: 'menu', 'data-target': 'expand.content') do
          capture(&block)
        end
    end
  end
  end
end
