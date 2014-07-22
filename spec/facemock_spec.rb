require 'spec_helper'

describe Facemock do
  let(:version) { "0.0.1" }

  describe 'VERSION' do
    subject { Facemock::VERSION }
    it { is_expected.to eq version }
  end
end
