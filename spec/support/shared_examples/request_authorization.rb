# frozen_string_literal: true

# Shared helpers for request-level authorization assertions.
# Use include_examples inside a describe/context block (not inside an it block).

RSpec.shared_examples "unauthenticated redirect" do
  it "redirects to sign in" do
    expect(response).to redirect_to(new_user_session_path)
  end
end

RSpec.shared_examples "not authorized redirect" do
  it "redirects with not authorized flash" do
    expect(flash[:alert]).to eq("You are not authorized to access this page.")
    expect(response).to be_redirect
  end
end
