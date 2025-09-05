# frozen_string_literal: true

RSpec.describe Matchers::InvokeMatcher do
  describe "#matches?" do
    it "raises an error if .on is not called" do
      matcher = described_class.new(:some_method)

      expect { matcher.matches?(proc {}) }
        .to raise_error(ArgumentError, "missing '.on'")
    end

    it "returns true when the method is called" do
      recipient = Object.new
      matcher = described_class.new(:to_s).on(recipient)

      result = matcher.matches?(proc { recipient.to_s })

      expect(result).to be(true)
    end

    it "returns false when the method is not called" do
      recipient = Object.new
      matcher = described_class.new(:to_s).on(recipient)

      result = matcher.matches?(proc {})

      expect(result).to be(false)
    end

    it "returns false when the method is called the wrong number of times" do
      recipient = Object.new
      matcher = described_class.new(:to_s).on(recipient).twice

      result = matcher.matches?(proc { recipient.to_s })

      expect(result).to be(false)
    end

    it "returns true when the method is called once with `once`" do
      recipient = Object.new
      matcher = described_class.new(:to_s).on(recipient).once

      result = matcher.matches?(proc { recipient.to_s })

      expect(result).to be(true)
    end

    it "returns true when the method is called twice with `twice`" do
      recipient = Object.new
      matcher = described_class.new(:to_s).on(recipient).twice

      result = matcher.matches?(proc { 2.times { recipient.to_s } })

      expect(result).to be(true)
    end

    it "returns true when the method is called with the expected arguments" do
      recipient = Object.new
      matcher = described_class.new(:gsub).on(recipient).with("a", "b")

      result = matcher.matches?(proc { recipient.gsub("a", "b") })

      expect(result).to be(true)
    end

    it "returns false when the method is called with the wrong arguments" do
      recipient = Object.new
      matcher = described_class.new(:gsub).on(recipient).with("a", "b")

      result = matcher.matches?(proc { recipient.gsub("a", "c") })

      expect(result).to be(false)
    end

    it "allows setting a return value" do
      recipient = Object.new
      matcher = described_class.new(:to_s).on(recipient).and_return("mocked")
      returned = nil

      matcher.matches?(proc { returned = recipient.to_s })

      expect(returned).to eq("mocked")
    end

    it "allows calling the original method" do
      recipient = Object.new
      matcher = described_class.new(:to_s).on(recipient).and_call_original
      returned = nil

      matcher.matches?(proc { returned = recipient.to_s })

      expect(returned).to match(/#<Object:0x\h+>/)
    end
  end
end
