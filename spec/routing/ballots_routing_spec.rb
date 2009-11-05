require 'spec_helper'

describe BallotsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/ballots" }.should route_to(:controller => "ballots", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/ballots/new" }.should route_to(:controller => "ballots", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/ballots/1" }.should route_to(:controller => "ballots", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/ballots/1/edit" }.should route_to(:controller => "ballots", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/ballots" }.should route_to(:controller => "ballots", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/ballots/1" }.should route_to(:controller => "ballots", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/ballots/1" }.should route_to(:controller => "ballots", :action => "destroy", :id => "1") 
    end
  end
end
