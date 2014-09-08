require 'fb_graph'

module Facemock
  module FbGraph
    class Exception                < ::FbGraph::Exception; end
    class BadRequest               < ::FbGraph::BadRequest; end
    class Unauthorized             < ::FbGraph::Unauthorized; end
    class NotFound                 < ::FbGraph::NotFound; end
    class InternalServerError      < ::FbGraph::InternalServerError; end
    class InvalidToken             < ::FbGraph::InvalidToken; end
    class InvalidSession           < ::FbGraph::InvalidSession; end
    class InvalidRequest           < ::FbGraph::InvalidRequest; end
    class CreativeNotSaved         < ::FbGraph::CreativeNotSaved; end
    class QueryLockTimeout         < ::FbGraph::QueryLockTimeout; end
    class TargetingSpecNotSaved    < ::FbGraph::TargetingSpecNotSaved; end
    class AdgroupFetchFailure      < ::FbGraph::AdgroupFetchFailure; end
    class OpenProcessFailure       < ::FbGraph::OpenProcessFailure; end
    class TransactionCommitFailure < ::FbGraph::TransactionCommitFailure; end
    class QueryError               < ::FbGraph::QueryError; end
    class QueryConnection          < ::FbGraph::QueryConnection; end
    class QueryDuplicateKey        < ::FbGraph::QueryDuplicateKey; end
  end
end
