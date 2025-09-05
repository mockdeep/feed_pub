# frozen_string_literal: true

RSpec.describe FeedPub::Retry do
  def fail_proc(times)
    expect(described_class).to receive(:sleep).exactly([times, 4].min).times

    attempt = 0

    proc do
      attempt += 1
      raise StandardError, "fail" if attempt <= times
    end
  end

  it "retries the block on failure" do
    expect { described_class.call(&fail_proc(2)) }.not_to raise_error
  end

  it "raises an error after max attempts" do
    expect { described_class.call(&fail_proc(5)) }.to raise_error("fail")
  end
end
