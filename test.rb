require "minitest/autorun"
require_relative "lib/nakitwitch"

describe Twitch do
  it "banwords" do
    assert_equal "<censored>", Twitch.banword("негр")
    assert_equal "!<censored>!", Twitch.banword("!негр!")
    assert_equal "<censored><censored>", Twitch.banword("негрпидарас")
    assert_equal " <censored> <censored> ", Twitch.banword(" нигер пидорас ")
  end
end
