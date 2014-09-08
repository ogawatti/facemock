require 'spec_helper'

describe Facemock::FbGraph::Exception do
  describe 'Exception' do
    subject { Facemock::FbGraph::Exception }
    it { is_expected.not_to be_nil }
  end
end

describe Facemock::FbGraph do
  describe 'BadRequest' do
    subject { Facemock::FbGraph::BadRequest.ancestors }
    it { is_expected.to include ::FbGraph::BadRequest }
  end

  describe 'Unauthorized' do
    subject { Facemock::FbGraph::Unauthorized.ancestors }
    it { is_expected.to include ::FbGraph::Unauthorized }
  end

  describe 'NotFound' do
    subject { Facemock::FbGraph::NotFound.ancestors }
    it { is_expected.to include ::FbGraph::NotFound }
  end

  describe 'InternalServerError' do
    subject { Facemock::FbGraph::InternalServerError.ancestors }
    it { is_expected.to include ::FbGraph::InternalServerError }
  end

  describe 'InvalidToken' do
    subject { Facemock::FbGraph::InvalidToken.ancestors }
    it { is_expected.to include ::FbGraph::InvalidToken }
  end

  describe 'InvalidSession' do
    subject { Facemock::FbGraph::InvalidSession.ancestors }
    it { is_expected.to include ::FbGraph::InvalidSession }
  end

  describe 'InvalidRequest' do
    subject { Facemock::FbGraph::InvalidRequest.ancestors }
    it { is_expected.to include ::FbGraph::InvalidRequest }
  end

  describe 'CreativeNotSaved' do
    subject { Facemock::FbGraph::CreativeNotSaved.ancestors }
    it { is_expected.to include ::FbGraph::CreativeNotSaved }
  end

  describe 'QueryLockTimeout' do
    subject { Facemock::FbGraph::QueryLockTimeout.ancestors }
    it { is_expected.to include ::FbGraph::QueryLockTimeout }
  end

  describe 'TargetingSpecNotSaved' do
    subject { Facemock::FbGraph::TargetingSpecNotSaved.ancestors }
    it { is_expected.to include ::FbGraph::TargetingSpecNotSaved }
  end

  describe 'AdgroupFetchFailure' do
    subject { Facemock::FbGraph::AdgroupFetchFailure.ancestors }
    it { is_expected.to include ::FbGraph::AdgroupFetchFailure }
  end

  describe 'OpenProcessFailure' do
    subject { Facemock::FbGraph::OpenProcessFailure.ancestors }
    it { is_expected.to include ::FbGraph::OpenProcessFailure }
  end

  describe 'TransactionCommitFailure' do
    subject { Facemock::FbGraph::TransactionCommitFailure.ancestors }
    it { is_expected.to include ::FbGraph::TransactionCommitFailure }
  end

  describe 'QueryError' do
    subject { Facemock::FbGraph::QueryError.ancestors }
    it { is_expected.to include ::FbGraph::QueryError }
  end

  describe 'QueryConnection' do
    subject { Facemock::FbGraph::QueryConnection.ancestors }
    it { is_expected.to include ::FbGraph::QueryConnection }
  end

  describe 'QueryDupulicateKey' do
    subject { Facemock::FbGraph::QueryDuplicateKey.ancestors }
    it { is_expected.to include ::FbGraph::QueryDuplicateKey }
  end
end
