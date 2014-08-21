require 'spec_helper'

describe Facemock::Database::Table do
  include TableHelper

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

  before do
    stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
    create_tables_table_for_test
  end

  after do
    Facemock::Database.new.drop
    remove_dynamically_defined_class_method(Facemock::Database::Table)
    remove_dynamically_defined_instance_method(Facemock::Database::Table)
  end

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
      before { @table.save! }

      subject { lambda { @table.save! } }
      it { is_expected.not_to raise_error }

      it 'should not change id and created_at' do
        id = @table.id
        created_at = @table.created_at
        @table.save!
        expect(@table.id).to eq id
        expect(@table.created_at).to eq created_at
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

        context 'with option that does not include column name' do
          before { @options = { hoge: "hoge" } }
          subject { lambda { @table.update_attributes!(@options) } }
          it { is_expected.to raise_error NoMethodError }
        end

        context 'when any column values does not change' do
          it 'should not change created_at value' do
            created_at = @table.created_at
            @table.update_attributes!({ created_at: created_at })
            expect(@table.created_at).to eq created_at
          end
        end

        context 'when created_at column changes' do
          it 'should change created_at value' do
            created_at = @table.created_at + 60
            @table.update_attributes!({ created_at: created_at })
            expect(@table.created_at).to eq created_at
          end
        end
      end
    end
  end

  describe '#destroy!' do
    before { @table = Facemock::Database::Table.new }

    context 'after records is saved' do
      before { @table.save! }
      subject { lambda { @table.destroy } }
      it { is_expected.not_to raise_error }
    end

    context 'when tables table has two record' do
      before do
        @table.save!
        Facemock::Database::Table.new.save!
      end

      it 'should delete one record' do
        expect(Facemock::Database::Table.all.count).to eq 2
        @table.destroy
        expect(Facemock::Database::Table.all.count).to eq 1
        expect(Facemock::Database::Table.find_by_id(@table.id)).to eq nil
      end
    end
  end

  describe '.all' do
    context 'when tables record does not exist' do
      subject { Facemock::Database::Table.all }

      it { is_expected.to be_kind_of Array }
      it { is_expected.to be_empty }
    end

    context 'when tables record exists' do
      before do
        @ids = 3.times.inject([]) do |ary, i| 
          table = Facemock::Database::Table.new.save!
          ary << table.id
        end
      end

      it 'should be array and should have three Table instances' do
        tables = Facemock::Database::Table.all
        expect(tables).to be_kind_of Array
        expect(tables.count).to eq 3
        tables.each do |table|
          expect(table).to be_kind_of Facemock::Database::Table
          expect(@ids).to be_include table.id
        end
      end
    end
  end

  describe '.first' do
    context 'when tables record does not exist' do
      subject { Facemock::Database::Table.first }
      it { is_expected.to be_nil }
    end

    context 'when tables record exists' do
      before do
        @ids = 3.times.inject([]) do |ary, i| 
          table = Facemock::Database::Table.new.save!
          ary << table.id
        end
      end

      it 'should be Table instances and id is the smallest' do
        finded = Facemock::Database::Table.first
        expect(finded).to be_kind_of Facemock::Database::Table
        expect(finded.id).to eq @ids.sort.first
      end
    end
  end

  describe '.last' do
    context 'when tables record does not exist' do
      subject { Facemock::Database::Table.last }
      it { is_expected.to be_nil }
    end

    context 'when tables record exists' do
      before do
        @ids = 3.times.inject([]) do |ary, i| 
          table = Facemock::Database::Table.new.save!
          ary << table.id
        end
      end

      it 'should be Table instances and id is biggest' do
        finded = Facemock::Database::Table.last
        expect(finded).to be_kind_of Facemock::Database::Table
        expect(finded.id).to eq @ids.sort.last
      end
    end
  end

  describe '.where' do
    context 'when tables record does not exist' do
      subject { Facemock::Database::Table.where(id: 1) }
      it { is_expected.to be_kind_of Array }
      it { is_expected.to be_empty }
    end

    context 'when tables record exists' do
      before do
        @ids = 3.times.inject([]) do |ary, i| 
          table = Facemock::Database::Table.new.save!
          ary << table.id
        end
      end

      it 'should be Array and should have only a Table instances' do
        @ids.each do |id|
          finded = Facemock::Database::Table.where(id: id)
          expect(finded).to be_kind_of Array
          expect(finded.count).to eq 1
          expect(finded.first).to be_kind_of Facemock::Database::Table
          expect(finded.first.id).to eq id
        end
      end
    end
  end

  describe '.method_missing' do
    context 'method name does not include find_by and find_all_by' do
      subject { lambda { Facemock::Database::Table.find_hoge } }
      it { is_expected.to raise_error NoMethodError }
    end

    context 'method name does not inlcude column name' do
      context 'without argument' do
        subject { lambda { Facemock::Database::Table.find_by_hoge } }
        it { is_expected.to raise_error NoMethodError }
      end

      context 'with argument' do
        subject { lambda { Facemock::Database::Table.find_by_hoge("hoge") } }
        it { is_expected.to raise_error NoMethodError }
      end
    end

    context 'method name inlcudes by_column_name' do
      context 'without argument' do
        subject { lambda { Facemock::Database::Table.find_by_id } }
        it { is_expected.to raise_error ArgumentError }
      end

      describe '.find_by_id' do
        context 'with not id' do
          subject { Facemock::Database::Table.find_by_id("hoge") }
          it { is_expected.to be_nil }
        end

        context 'with id' do
          context 'when record does not exist' do
            subject { Facemock::Database::Table.find_by_id(1) }
            it { is_expected.to be_nil }
          end

          context 'when record exists' do
            it 'should be Table instance' do
              created = Facemock::Database::Table.new.save!
              finded  = Facemock::Database::Table.find_by_id(created.id)
              expect(finded).to be_kind_of Facemock::Database::Table
              expect(finded.id).to eq created.id
              finded.instance_variables.each do |key|
                expect(finded.instance_variable_get(key)).to eq created.instance_variable_get(key)
              end
            end
          end
        end
      end

      describe '.find_by_created_at' do
        context 'with not created_at' do
          subject { Facemock::Database::Table.find_by_created_at("hoge") }
          it { is_expected.to be_nil }
        end

        context 'with created_at' do
          context 'when record does not exist' do
            subject { Facemock::Database::Table.find_by_created_at(Time.now) }
            it { is_expected.to be_nil }
          end

          context 'when record exists' do
            it 'should be Table instance' do
              created = Facemock::Database::Table.new.save!
              finded  = Facemock::Database::Table.find_by_created_at(created.created_at)
              expect(finded).to be_kind_of Facemock::Database::Table
              expect(finded.id).to eq created.id
              finded.instance_variables.each do |key|
                expect(finded.instance_variable_get(key)).to eq created.instance_variable_get(key)
              end
            end
          end
        end
      end
    end

    context 'method name includes find_all_by_column_name' do
      context 'without argument' do
        subject { lambda { Facemock::Database::Table.find_all_by_id } }
        it { is_expected.to raise_error ArgumentError }
      end

      describe '.find_all_by_id' do
        context 'with not id' do
          subject { Facemock::Database::Table.find_all_by_id("hoge") }
          it { is_expected.to be_empty }
        end

        context 'with id' do
          context 'when record does not exist' do
            subject { Facemock::Database::Table.find_all_by_id(1) }
            it { is_expected.to be_empty }
          end

          context 'when record exists' do
            it 'should be array and should have only one Table instances' do
              created = Facemock::Database::Table.new.save!
              tables  = Facemock::Database::Table.find_all_by_id(created.id)
              expect(tables).to be_kind_of Array
              expect(tables.count).to eq 1
              tables.each do |finded|
                finded.instance_variables.each do |key|
                  expect(finded.instance_variable_get(key)).to eq created.instance_variable_get(key)
                end
              end
            end
          end
        end
      end

      describe '.find_all_by_created_at' do
        context 'with not created_at' do
          subject { Facemock::Database::Table.find_all_by_created_at("hoge") }
          it { is_expected.to be_empty }
        end

        context 'with created_at' do
          context 'when record does not exist' do
            subject { Facemock::Database::Table.find_all_by_created_at(Time.now) }
            it { is_expected.to be_empty }
          end

          context 'when record exists' do
            it 'should be Table instance' do
              created = Facemock::Database::Table.new.save!
              created_at = created.created_at
              updated = Facemock::Database::Table.new.save!
              updated.created_at = created_at
              updated.save!

              tables = Facemock::Database::Table.find_all_by_created_at(created_at)
              expect(tables).to be_kind_of Array
              expect(tables.count).to eq 2
              tables.each do |finded|
                expect(finded).to be_kind_of Facemock::Database::Table
                expect(finded.created_at).to eq created_at
              end
            end
          end
        end
      end
    end
  end

  describe '#method_missing' do
    before { @table = Facemock::Database::Table.new.save! }

    context 'when method is getter' do
      describe '#id' do
        subject { @table.id }
        it { is_expected.to be_kind_of Integer }
      end

      describe '#identifier' do
        subject { @table.identifier }
        it { is_expected.to eq @table.id }
      end
    end

    context 'when method is setter' do
      describe '#id=' do
        before { @id = 1 }
          
        it 'should set attribute to id' do
          expect(@table.id).to be_kind_of Integer
          @table.id = @id
          expect(@table.id).to eq @id
        end
      end

      describe '#identifier=' do
        before { @id = 1 }

        it 'should set attribute to id' do
          expect(@table.identifier).to be_kind_of Integer
          @table.identifier = @id
          expect(@table.id).to eq @id
          expect(@table.identifier).to eq @table.id
        end
      end
    end
  end

  describe '.table_info' do
    subject { Facemock::Database::Table.table_info }
    it { is_expected.to be_kind_of Hashie::Mash }

    it 'has keys that is id and created_at' do
      table_info = Facemock::Database::Table.table_info
      table_info.each_keys do |key|
        expect(key.to_sym).to include column_names
      end
    end

    context 'then keys' do
      before { @table_info = Facemock::Database::Table.table_info }

      describe '#id' do
        subject { @table_info.id }
        it { is_expected.to be_kind_of Hashie::Mash }

        it 'should have column_info' do
          expect(@table_info.id.cid).to eq 0
          expect(@table_info.id.name).to eq :id
          expect(@table_info.id.type).to eq "INTEGER"
          expect(@table_info.id.notnull).to eq false
          expect(@table_info.id.dflt_value).to be_nil
          expect(@table_info.id.pk).to eq true
        end
      end
        
      describe '#created_at' do
        subject { @table_info.created_at }
        it { is_expected.to be_kind_of Hashie::Mash }

        it 'should have column_info' do
          expect(@table_info.created_at.cid).to eq 1
          expect(@table_info.created_at.name).to eq :created_at
          expect(@table_info.created_at.type).to eq "DATETIME"
          expect(@table_info.created_at.notnull).to eq true
          expect(@table_info.created_at.dflt_value).to be_nil
          expect(@table_info.created_at.pk).to eq false
        end
      end
    end
  end

  describe '.column_type' do
    context 'without argument' do
      subject { lambda { Facemock::Database::Table.column_type } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with not column name' do
      subject { Facemock::Database::Table.column_type(:hoge) }
      it { is_expected.to be_nil }
    end

    context 'with id' do
      subject { Facemock::Database::Table.column_type(:id) }
      it { is_expected.to eq "INTEGER" }
    end

    context 'with created_at' do
      subject { Facemock::Database::Table.column_type(:created_at) }
      it { is_expected.to eq "DATETIME" }
    end
  end
end
