require File.dirname(__FILE__) + '/spec_helper'

describe TwitterDispatch do
  describe '#new' do
    it 'should raise an ArgumentError for non-existent strategies' do
      lambda{TwitterDispatch.new(:bollocks)}.should raise_error(ArgumentError)  
    end

    { :oauth => 4,
      :basic => 2,
      :none => 0 }.each_pair do |strategy, count|
      it "should raise an ArgumentError with the wrong number of args for #{strategy.inspect}" do
        (0...count).each do |arg_count|
          myargs = ['abc'] * arg_count
          lambda{TwitterDispatch.new(strategy, *myargs)}.should raise_error(ArgumentError)
          myargs << {:base_url => 'http://example.com'}
          lambda{TwitterDispatch.new(strategy, *myargs)}.should raise_error(ArgumentError)
        end
      end

      it "should not raise an ArgumentError with the correct number of arguments for #{strategy.inspect}" do
        myargs = ['abc'] * count
        lambda{TwitterDispatch.new(strategy, *myargs)}.should_not raise_error(ArgumentError)
        myargs << {:base_url => 'http://example.com'}
        lambda{TwitterDispatch.new(strategy, *myargs)}.should_not raise_error(ArgumentError)
      end

      unless strategy == :none
        it "should set the strategy appropriately" do
          myargs = ['abc'] * count
          @dispatch = TwitterDispatch.new(strategy, *myargs)
          @dispatch.strategy.should == strategy
          @dispatch.should be_strategy
          @dispatch.send("#{strategy}?").should be_true
        end
      end
    end

    it '#strategy? should be false if the :none strategy is used' do
      TwitterDispatch.new(:none).should_not be_strategy
    end

    it '#strategy should default to none' do
      TwitterDispatch.new.strategy.should == :none
    end
  end
end
