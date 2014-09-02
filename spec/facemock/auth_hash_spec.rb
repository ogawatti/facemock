require 'spec_helper'

describe Facemock::AuthHash do
  it 'should inherit a OmniAuth::AuthHash class' do
    expect(Facemock::AuthHash.ancestors).to include OmniAuth::AuthHash
  end
end
