require 'spec_helper'

describe Facemock::FbGraph::Application::User::Right do
  let(:table_name) { "user_rights" }

  describe '.table_name' do
    subject { Facemock::FbGraph::Application::User::Right.table_name }
    it { is_expected.to eq table_name }
  end
end
