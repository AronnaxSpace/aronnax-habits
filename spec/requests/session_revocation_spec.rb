describe "Session revocation", type: :request do
  let(:cookie_name) { Rails.application.config.session_options[:key] }

  before { mock_aronnax_auth }

  it "keeps a session working until the user signs out" do
    authenticate_with_aronnax

    get habits_url
    expect(response).to have_http_status(:ok)
  end

  it "rejects a copied session cookie after the user signs out" do
    authenticate_with_aronnax
    copied_cookie = cookies[cookie_name]

    delete destroy_user_session_path
    cookies[cookie_name] = copied_cookie
    get habits_url

    expect(response).to redirect_to(new_user_session_path)
  end

  it "lets the user sign in again after signing out" do
    authenticate_with_aronnax
    delete destroy_user_session_path

    authenticate_with_aronnax
    get habits_url

    expect(response).to have_http_status(:ok)
  end

  it "rotates the session salt on sign out" do
    authenticate_with_aronnax
    user = User.find_by!(uid: "aronnax-uid-123")

    expect { delete destroy_user_session_path }
      .to change { user.reload.authenticatable_salt }
  end

  it "leaves other users' session salts alone" do
    other = create(:user)

    authenticate_with_aronnax
    delete destroy_user_session_path

    expect(other.reload.session_salt).to be_nil
  end
end
