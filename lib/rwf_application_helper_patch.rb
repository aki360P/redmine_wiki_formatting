require 'application_helper'

module RwfApplicationHelperPatch

  def self.included(base)
    base.class_eval do
      #customize application_helper textilizable method
      alias_method :textilizable, :rwf_textilizable
    end
  end


  def rwf_textilizable(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    case args.size
    when 1
      obj = options[:object]
      text = args.shift
    when 2
      obj = args.shift
      attr = args.shift
      text = obj.send(attr).to_s
    else
      raise ArgumentError, 'invalid arguments to textilizable'
    end
    return '' if text.blank?

    project = options[:project] || @project || (obj && obj.respond_to?(:project) ? obj.project : nil)
    @only_path = only_path = options.delete(:only_path) == false ? false : true

    text = text.dup
    macros = catch_macros(text)

    ### plugin customize part ###
    pos1 = text.index("formatting=textile")
    pos2 = text.index("formatting=markdown")
    pos3 = text.index("formatting=common_mark")
    if not pos1.nil? then
      if pos1 < 20 then
        formatting = "textile"
        text.slice!("formatting=textile")
        text = Redmine::WikiFormatting.to_html(formatting, text, :object => obj, :attribute => attr)
      end
    elsif not pos2.nil? then
      if pos2 < 20 then
        formatting = "markdown"
        text.slice!("formatting=markdown")
        text = Redmine::WikiFormatting.to_html(formatting, text, :object => obj, :attribute => attr)
      end
    elsif not pos3.nil? then
      if pos3 < 20 then
        formatting = "common_mark"
        text.slice!("formatting=common_mark")
        text = Redmine::WikiFormatting.to_html(formatting, text, :object => obj, :attribute => attr)
      end
    elsif options[:formatting] == false
      text = h(text)
    else
      formatting = Setting.text_formatting
      text = Redmine::WikiFormatting.to_html(formatting, text, :object => obj, :attribute => attr)
    end
    ###

    @parsed_headings = []
    @heading_anchors = {}
    @current_section = 0 if options[:edit_section_links]

    parse_sections(text, project, obj, attr, only_path, options)
    text = parse_non_pre_blocks(text, obj, macros, options) do |text|
      [:parse_inline_attachments, :parse_hires_images, :parse_wiki_links, :parse_redmine_links].each do |method_name|
        send method_name, text, project, obj, attr, only_path, options
      end
    end
    parse_headings(text, project, obj, attr, only_path, options)

    if @parsed_headings.any?
      replace_toc(text, @parsed_headings)
    end

    text.html_safe
  end
end

ApplicationHelper.include(RwfApplicationHelperPatch)