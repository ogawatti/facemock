require 'spec_helper'
require 'pry'

describe Facemock::Database::Table do
  let(:db_name)         { ".test" }
  let(:table_name)      { :tables }
  let(:column_names)    { [:id, :created_at] }

  describe '::TABLE_NAME' do
    subject { Facemock::Database::Table::TABLE_NAME }
    it { is_expected.to eq table_name }
  end

  describe '::COLUMN_NAMES' do
    subject { Facemock::Database::Table::COLUMN_NAMES }
    it { is_expected.to eq column_names }
  end

  def create_table
    db = Facemock::Database.new
    db.connection.execute <<-SQL
      create table #{table_name} (
        id          integer   primary key AUTOINCREMENT,
        created_at  datetime  not null
      );
    SQL
    db.disconnect!
  end

  def select_all_record_by_id(id)
    db = Facemock::Database.new
    records = db.connection.execute <<-SQL
      select * from #{table_name} where id = #{id};
    SQL
    db.disconnect!
    records
  end

  before do
    stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
    create_table
  end
  after { Facemock::Database.new.drop }

  describe '#initialize' do
    context 'without option' do
      it 'should have accessor of column' do
        @table = Facemock::Database::Table.new
        column_names.each do |column_name|
           expect(@table.send(column_name)).to be_nil
        end

        @table.id = id = 1
        @table.created_at = created_at = Time.now
        expect(@table.id).to eq id
        expect(@table.created_at).to eq created_at 

        expect(lambda{ @table.name }).to raise_error NoMethodError
        expect(lambda{ @table.name = nil }).to raise_error NoMethodError
      end
    end

    context 'with option' do
      it 'should have accessor of column' do
        options = { id: 1 }
        @table = Facemock::Database::Table.new(options)
        expect(@table.id).to eq options[:id]
        expect(@table.created_at).to be_nil
      end
    end
  end

  describe '#save!' do
    before { @table = Facemock::Database::Table.new }

    context 'when id is nil' do
      it 'should insert table record to database' do
        @table.save!
        expect(@table.id).to be > 0
        expect(@table.created_at).to be <= Time.now
      end

      it 'should return table object' do
        table = @table.save!
        expect(table).to be_kind_of Facemock::Database::Table
        expect(table.id).to be > 0
        expect(table.created_at).to be <= Time.now
      end
    end

    context 'when id is specified but record does not exist' do
      before { @table.id = @id = 1 }

      it 'should insert table record to database' do
        @table.save!
        expect(@table.id).to eq @id
        expect(@table.created_at).to be <= Time.now
      end
    end

    context 'when id is specified and record exists' do
      before do
        @table.save!
        expect(@table).to receive(:update!).with(no_args()).once
      end

      subject { lambda { @table.save! } }
      it { is_expected.not_to raise_error }

      it 'calls update! method' do
        @table.save!
        expect(@table.id).to be > 0
        expect(@table.created_at).to be <= Time.now
      end
    end
  end

  describe '#update_attributes!' do
    before { @table = Facemock::Database::Table.new }

    context 'without options' do
      subject { lambda { @table.update_attributes! } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with options' do
      context 'after save!' do
        before { @table.save! }

        # shared_context を使うとcoverageに載らない...?
        shared_context 'specified column value should change', assert: :update_attributes_with_options do
          subject { @table.update_attributes!(@options) }

          it { expect(@table.id).to eq @id }
          it { expect(@table.created_at).to eq @created_at }
        end

        context 'with option that does not include column name' do
          before { @options = { hoge: "hoge" } }
          subject { lambda { @table.update_attributes!(@options) } }
          it { is_expected.to raise_error NoMethodError }
        end

        context 'when any column values does not change', assert: :update_attributes_with_options do
          before do
            @id = @table.id
            @created_at = @table.created_at
            @options = { created_at: @created_at }
          end
        end

        context 'when created_at column changes', assert: :update_attributes_with_options do
          before do
            @id = @table.id
            @table.created_at = @created_at = @table.created_at - 60
            @options = { created_at: @created_at }
          end
        end
      end
    end
  end
end
