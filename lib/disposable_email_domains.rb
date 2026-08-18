# frozen_string_literal: true

require_relative "disposable_email_domains/version"
require "set"
require "forwardable"

module DisposableEmailDomains
  class Error < StandardError; end

  class << self
    extend Forwardable

    def_delegators :set, :to_a

    def include?(mail)
      return false if mail.nil?

      domain = mail[/@(.+)/, 1]
      disposable?(domain)
    end

    def disposable?(domain)
      return false if domain.nil? || domain.empty?

      set.include?(domain) || subdomain_of_wildcard?(domain)
    end

    def set
      @@set ||= Set.new(from_datafile("domains.txt")) |
                from_datafile("domains_ext.txt") |
                from_datafile("deleted_domains.txt") |
                wildcard_set
    end

    def wildcard_set
      @@wildcard_set ||= Set.new(from_datafile("domains_wildcard.txt"))
    end

    private

    def subdomain_of_wildcard?(domain)
      candidate = domain

      while (dot = candidate.index("."))
        candidate = candidate[(dot + 1)..]
        return false unless candidate.include?(".")
        return true if wildcard_set.include?(candidate)
      end

      false
    end

    def from_datafile(file)
      path = File.join(File.dirname(File.expand_path(__FILE__)), "./../#{file}")
      File.read(path).split("\n")
    end
  end
end
