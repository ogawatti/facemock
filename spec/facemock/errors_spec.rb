require 'spec_helper'

describe Facemock::Errors do
  it 'should have a error module' do
    expect(Facemock::Errors::Error.ancestors).to include StandardError
    expect(Facemock::Errors::IncorrectDataFormat.ancestors).to include Facemock::Errors::Error
    expect(Facemock::Errors::ColumnTypeNotNull.ancestors).to include Facemock::Errors::Error
  end
end
