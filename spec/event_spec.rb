require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class DummyContextObject
  def initialize
    @test_var = 1
  end

  def incr
    @test_var += 1
  end

  def test_var
    @test_var
  end
end

describe Inferno::Event do
  it "should allow add actions and run it in proper context" do
    dummy         = DummyContextObject.new
    notifications = Inferno::Event.new
    notifications.on(:test, dummy) { @test_var = 2 }
    notifications.count(:test).should eq(1)
    notifications.trigger(:test)

    dummy.test_var.should eq(2)
  end

  it "should trigger event only once" do
    dummy         = DummyContextObject.new
    notifications = Inferno::Event.new
    notifications.once(:test, dummy) { dummy.incr }
    notifications.count(:test).should eq(2)
    dummy.test_var.should eq(1)
    10.times { notifications.trigger(:test) }

    dummy.test_var.should eq(2)
  end

  it "should remove events" do
    dummy         = DummyContextObject.new
    notifications = Inferno::Event.new

    notifications.on(:test, dummy) { @test_var = 2 }
    notifications.count(:test).should eq(1)
    notifications.off(:test, dummy)
    notifications.count(:test).should eq(0)

    notifications.on(:test, dummy) {}
    notifications.on(:test, self)  {}

    notifications.count(:test).should eq(2)

    notifications.off(:test, dummy)
    notifications.count(:test).should eq(1)

    notifications.off(:test, self)
    notifications.count(:test).should eq(0)
  end

  it "should allow transfer payloads" do
    notifications = Inferno::Event.new

    notifications.on(:test, self) do |payload|
      payload.should_not be_nil
      payload[:test].should eq(1)
    end
    notifications.trigger(:test, { test: 1 })
  end

end