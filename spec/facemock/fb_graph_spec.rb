require 'spec_helper'

describe Facemock::FbGraph do
  describe '#on' do
    subject { Facemock::FbGraph.on }
    it { is_expected.to be_truthy }

    context 'FbGraph' do
      before { Facemock::FbGraph.on }
      it { expect(::FbGraph).to eq Facemock::FbGraph }
      it { expect( lambda { Facemock::FbGraph.on } ).not_to raise_error }
    end
  end

  describe '#off' do
    subject { Facemock::FbGraph.off }
    it { is_expected.to be_truthy }

    context 'FbGraph' do
      before { Facemock::FbGraph.off }
      it { expect(FbGraph).to eq FbGraph }
      it { expect( lambda { Facemock::FbGraph.off } ).not_to raise_error }

      context 'when mock is on' do
        before do
          Facemock::FbGraph.on
          Facemock::FbGraph.off
        end

        subject { ::FbGraph }
        it { is_expected.to eq FbGraph }
      end
    end
  end
end
