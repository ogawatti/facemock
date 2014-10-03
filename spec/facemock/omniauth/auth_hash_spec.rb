require 'spec_helper'

describe Facemock::OmniAuth::AuthHash do
  it 'should inherit a ::OmniAuth::AuthHash class' do
    expect(Facemock::OmniAuth::AuthHash.ancestors).to include ::OmniAuth::AuthHash
  end
end
