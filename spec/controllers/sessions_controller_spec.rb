require 'spec_helper'

  describe SessionsController do
    describe "GET new" do
      it "renders the new template for un-authenticated users" do
        get :new
        expect(response).to render_template :new
      end

      it "redirects to the video index (videos_path) for authenticated users" do
        session[:user_id] = Fabricate(:user).id
        get :new
        expect(response).to redirect_to videos_path
      end
    end

    describe "POST create" do
    context "with valid credentials" do
      it "puts the signed in user, into the session" do
        paul = Fabricate(:user)
        post :create, email: paul.email, password: paul.password
        expect(session[:user_id]).to eq(paul.id)
      end

      it "redirects to the video index page" do
        paul = Fabricate(:user)
        post :create, email: paul.email, password: paul.password
        expect(response).to redirect_to videos_path
      end
      it "sets the notice to successful login" do 
        paul = Fabricate(:user)
        post :create, email: paul.email, password: paul.password
        expect(flash[:notice]).to start_with 'Success'
      end
    end
 
    context "with valid credentials but suspended account" do
      it "redirects the user to the front page" do
        simon = Fabricate(:user, active: false)
        post :create, email: simon.email, password: simon.password
        expect(response).to redirect_to login_path        
      end

      it "sets a flash message to have user contact a site admin" do
        simon = Fabricate(:user, active: false)
        post :create, email: simon.email, password: simon.password
        expect(flash[:error]).to eq("We're sorry but your account has been suspended. Please contact an administrator.")
      end
    end


    context "with invalid credentials" do
      it "does not put the user into the session" do
        paul = Fabricate(:user)
        post :create, email: paul.email, password: 'incorrect password'
        expect(session[:user_id]).to eq(nil)      
      end
      it "redirects the user to the login page" do
        paul = Fabricate(:user)
        post :create, email: paul.email, password: 'incorrect password'
        expect(response).to redirect_to login_path
      end
      it "sets the error message" do 
        paul = Fabricate(:user)
        post :create, email: paul.email, password: 'incorrect password'
        expect(flash[:error]).to start_with "Invalid"
      end
    end
  end
  describe "GET destroy" do
    it "sets the session user_id to nil" do  
      paul = Fabricate(:user)
      session[:user_id] = paul.id
      get :destroy
      expect(session[:user_id]).to eq(nil)
    end
    it "sets the notice to logged out" do
      paul = Fabricate(:user)
      session[:user_id] = paul.id
      get :destroy
      expect(flash[:error]).to start_with "You've logged out"
    end
    it "redirects to the front page aka root path" do
      paul = Fabricate(:user)
      session[:user_id] = paul.id
      get :destroy
      expect(response).to redirect_to root_path
    end
  end
end