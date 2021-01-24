# frozen_string_literal: true

require "monitor"
require "observer"
require "singleton"

module CableReady
  # This class is a process level singleton shared by all threads: CableReady::Config.instance
  class Config
    include MonitorMixin
    include Observable
    include Singleton

    def initialize
      super
      @operation_names = Set.new(default_operation_names)
    end

    def operation_names
      @operation_names.to_a
    end

    def add_operation_name(name)
      synchronize do
        @operation_names << name.to_sym
        notify_observers name.to_sym
      end
    end

    def default_operation_names
      Set.new(%i[
        add_css_class
        append
        clear_storage
        console_log
        dispatch_event
        go
        inner_html
        insert_adjacent_html
        insert_adjacent_text
        morph
        notification
        outer_html
        prepend
        push_state
        remove
        remove_attribute
        remove_css_class
        remove_storage_item
        replace
        replace_state
        set_attribute
        set_cookie
        set_dataset_property
        set_focus
        set_property
        set_storage_item
        set_style
        set_styles
        set_value
        text_content
      ]).freeze
    end
  end
end
