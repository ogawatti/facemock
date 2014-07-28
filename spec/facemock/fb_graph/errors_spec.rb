require 'spec_helper'

describe Facemock::FbGraph::Errors do
  before do
    Facemock::FbGraph.off
  end

  it 'should have a error module' do
    expect(Facemock::FbGraph::Errors::Error).to be_truthy
    expect(Facemock::FbGraph::Errors::Error.ancestors).to include StandardError
    expect(Facemock::FbGraph::Errors::InvalidToken.ancestors).to include FbGraph::InvalidToken
  end
end
