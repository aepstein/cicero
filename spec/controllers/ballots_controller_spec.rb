require 'spec_helper'

describe BallotsController do

  def mock_ballot(stubs={})
    @mock_ballot ||= mock_model(Ballot, stubs)
  end

  describe "GET index" do
    it "assigns all ballots as @ballots" do
      Ballot.stub!(:find).with(:all).and_return([mock_ballot])
      get :index
      assigns[:ballots].should == [mock_ballot]
    end
  end

  describe "GET show" do
    it "assigns the requested ballot as @ballot" do
      Ballot.stub!(:find).with("37").and_return(mock_ballot)
      get :show, :id => "37"
      assigns[:ballot].should equal(mock_ballot)
    end
  end

  describe "GET new" do
    it "assigns a new ballot as @ballot" do
      Ballot.stub!(:new).and_return(mock_ballot)
      get :new
      assigns[:ballot].should equal(mock_ballot)
    end
  end

  describe "GET edit" do
    it "assigns the requested ballot as @ballot" do
      Ballot.stub!(:find).with("37").and_return(mock_ballot)
      get :edit, :id => "37"
      assigns[:ballot].should equal(mock_ballot)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created ballot as @ballot" do
        Ballot.stub!(:new).with({'these' => 'params'}).and_return(mock_ballot(:save => true))
        post :create, :ballot => {:these => 'params'}
        assigns[:ballot].should equal(mock_ballot)
      end

      it "redirects to the created ballot" do
        Ballot.stub!(:new).and_return(mock_ballot(:save => true))
        post :create, :ballot => {}
        response.should redirect_to(ballot_url(mock_ballot))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved ballot as @ballot" do
        Ballot.stub!(:new).with({'these' => 'params'}).and_return(mock_ballot(:save => false))
        post :create, :ballot => {:these => 'params'}
        assigns[:ballot].should equal(mock_ballot)
      end

      it "re-renders the 'new' template" do
        Ballot.stub!(:new).and_return(mock_ballot(:save => false))
        post :create, :ballot => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested ballot" do
        Ballot.should_receive(:find).with("37").and_return(mock_ballot)
        mock_ballot.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :ballot => {:these => 'params'}
      end

      it "assigns the requested ballot as @ballot" do
        Ballot.stub!(:find).and_return(mock_ballot(:update_attributes => true))
        put :update, :id => "1"
        assigns[:ballot].should equal(mock_ballot)
      end

      it "redirects to the ballot" do
        Ballot.stub!(:find).and_return(mock_ballot(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(ballot_url(mock_ballot))
      end
    end

    describe "with invalid params" do
      it "updates the requested ballot" do
        Ballot.should_receive(:find).with("37").and_return(mock_ballot)
        mock_ballot.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :ballot => {:these => 'params'}
      end

      it "assigns the ballot as @ballot" do
        Ballot.stub!(:find).and_return(mock_ballot(:update_attributes => false))
        put :update, :id => "1"
        assigns[:ballot].should equal(mock_ballot)
      end

      it "re-renders the 'edit' template" do
        Ballot.stub!(:find).and_return(mock_ballot(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested ballot" do
      Ballot.should_receive(:find).with("37").and_return(mock_ballot)
      mock_ballot.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the ballots list" do
      Ballot.stub!(:find).and_return(mock_ballot(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(ballots_url)
    end
  end

end
