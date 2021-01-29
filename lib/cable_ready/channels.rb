# frozen_string_literal: true

require "thread/local"
require_relative "channel"

module CableReady
  # This class is a thread local singleton: CableReady::Channels.instance
  # SEE: https://github.com/socketry/thread-local/tree/master/guides/getting-started
  class Channels
    extend Thread::Local

    attr_accessor :operations

    def initialize
      @channels = {}
      @operations = {}
    end

    def [](*keys)
      keys.select! &:itself
      identifier = keys.one? ? keys.pop : compound(keys)
      @channels[identifier] ||= CableReady::Channel.new(identifier)
    end

    def broadcast(*identifiers, clear: true)
      @channels.values
        .reject { |channel| identifiers.any? && identifiers.exclude?(channel.identifier) }
        .select { |channel| channel.identifier.is_a?(String) }
        .tap do |channels|
          channels.each { |channel| @channels[channel.identifier].broadcast(clear: clear) }
          channels.each { |channel| @channels.except!(channel.identifier) if clear }
        end
    end

    def broadcast_to(model, *identifiers, clear: true)
      @channels.values
        .reject { |channel| identifiers.any? && identifiers.exclude?(channel.identifier) }
        .reject { |channel| channel.identifier.is_a?(String) }
        .tap do |channels|
          channels.each { |channel| @channels[channel.identifier].broadcast_to(model, clear: clear) }
          channels.each { |channel| @channels.except!(channel.identifier) if clear }
        end
    end

    private

    def compound(keys)
      keys.map do |key|
        key.class < ActiveRecord::Base ? key.to_sgid(expires_in: nil).to_s : key.to_s
      end.join(":")
    end
  end
end
