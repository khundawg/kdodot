require 'spec_helper'

describe UserSessionsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end

    it "renders the new template" do
      get 'new'
      expect(response).to render_template('new')
    end 
  end

  describe "POST 'create'" do

    context "with correct credentials" do

      let!(:user) { User.create( first_name: "Dave", 
                            last_name: "Moore", 
                            email: "dave@example.com", 
                            password: "qwerty", 
                            password_confirmation: "qwerty"
      )}

      it "redirects to the todo list path" do
        post :create, email: "dave@example.com", password: "qwerty"
        expect(response).to be_redirect
        expect(response).to redirect_to(todo_lists_path)
      end

      it "finds the user" do
        expect(User).to receive(:find_by).with({email: "dave@example.com"}).and_return(user)
        post :create, email: "dave@example.com", password: "qwerty"
      end

      it "authenticates the user" do
        User.stub(:find_by).and_return(user)
        expect(user).to receive(:authenticate)
        post :create, email: "dave@example.com", password: "qwerty"
      end

      it "sets the user_id in the session" do
        post :create, email: "dave@example.com", password: "qwerty"
        expect(session[:user_id]).to eq(user.id)
      end

      it "sets the flash success message" do
        post :create, email: "dave@example.com", password: "qwerty"
        expect(flash[:success]).to eq("Thank you for logging in!")
      end
    end

    shared_examples_for "denied login" do

      it "renders the new template" do
        post :create, email: email, password: password
        expect(response).to render_template('new')
      end

      it "sets the flash error message when users cannot log in" do
        post :create, email: email, password: password
        expect(flash[:error]).to eq("There was an error with your credentials.  Please check your email and password.")
      end
    end

    context "with blank credentials" do
      let(:email) {""}
      let(:password) {""}

      it_behaves_like "denied login"
    end

    context "with incorrect password" do
      let!(:user) { User.create( first_name: "Dave", 
                            last_name: "Moore", 
                            email: "dave@example.com", 
                            password: "qwerty", 
                            password_confirmation: "qwerty"
      )}
      let(:email) {user.email}
      let(:password) {"asdfg"}

      it_behaves_like "denied login"
    end

    context "with no email in the database" do
      let(:email) {"someemail@example.com"}
      let(:password) {"asdfg"}

      it_behaves_like "denied login"
    end
  end

end

