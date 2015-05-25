require 'spec_helper'

describe Facemock::AccessToken do
  let(:db_name)         { ".test" }
  let(:column_names)    { [ :id, :string, :user_id, :application_id, :created_at ] }

  let(:id)              { 1 }
  let(:string)          { "test_code" }
  let(:user_id)         { 1 }
  let(:application_id)  { 1 }
  let(:created_at)      { Time.now }
  let(:options)         { { id:             id, 
                            string:         string, 
                            user_id:        user_id, 
                            application_id: application_id, 
                            created_at:     created_at } }

  describe '#initialize' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'without option' do
      subject { Facemock::AccessToken.new }
      it { is_expected.to be_kind_of Facemock::AccessToken }

      context 'then attributes' do
        it 'should be nil except string' do
          column_names.each do |column_name|
            value = Facemock::AccessToken.new.send(column_name)
            if column_name == :string
              expect(value).not_to be_nil
            else
              expect(value).to be_nil
            end
          end
        end
      end

      context 'then string' do
        it 'should be random string' do
          string1 = Facemock::AccessToken.new.string
          string2 = Facemock::AccessToken.new.string
          expect(string1).to be_kind_of String
          expect(string1.size).to eq 255
          expect(string1).not_to eq string2
        end
      end
    end

    context 'with all options' do
      subject { Facemock::AccessToken.new(options) }
      it { is_expected.to be_kind_of Facemock::AccessToken }

      context 'then attributes' do
        it 'should set specified value by option' do
          column_names.each do |column_name|
            value = Facemock::AccessToken.new(options).send(column_name)
            expect(value).to eq options[column_name]
          end
        end
      end
    end
  end

  describe '#application' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'when application_id is empty' do
      before { @access_token = Facemock::AccessToken.new }
      subject { @access_token.application }
      it { is_expected.to be_nil }
    end

    context 'when application_id is specified' do
      before do
        @application = Facemock::Application.create!
        @access_token = Facemock::AccessToken.new(application_id: @application.id)
      end

      subject { @access_token.application.id }
      it { is_expected.to eq @application.id }
    end
  end

  describe '#user' do
    before { @database = Facemock::Database.new(db_name) }
    after  { @database.drop }

    context 'when user_id is empty' do
      before { @access_token = Facemock::AccessToken.new }
      subject { @access_token.application }
      it { is_expected.to be_nil }
    end

    context 'when user_id is specified' do
      before do
        @user = Facemock::User.create!
        @access_token = Facemock::AccessToken.new(user_id: @user.id)
      end

      subject { @access_token.user.id }
      it { is_expected.to eq @user.id }
    end
  end

  describe '#permissions' do
    before { @database = Facemock::Database.new(db_name) }
    after  { @database.drop }

    context 'when does not have permission' do
      before { @access_token = Facemock::AccessToken.new }
      subject { @access_token.permissions }
      it { is_expected.to be_empty }
    end

    context 'when have any permissions' do
      before do
        @access_token = Facemock::AccessToken.create!(user_id: 1, application_id: 1)
        @permission1  = Facemock::Permission.create!(name: "test1", access_token_id: @access_token.id)
        @permission2  = Facemock::Permission.create!(name: "test2", access_token_id: @access_token.id)
      end
      subject { @access_token.permissions }
      it { is_expected.not_to be_empty }

      it 'should include its' do
        expect(@access_token.permissions.first.id).to eq @permission1.id
        expect(@access_token.permissions.last.id).to eq @permission2.id
      end
    end
  end

  describe '#destroy' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'when has permissions' do
      before do
        application = Facemock::Application.create!
        user = Facemock::User.create!
        options = { application_id: application.id, user_id: user.id }
        @access_token = Facemock::AccessToken.create!(options)
        Facemock::Permission.create!(access_token_id: @access_token.id, name: "test")
      end

      it 'should delete permissions' do
        @access_token.destroy
        permissions = Facemock::Permission.find_all_by_access_token_id(@access_token.id)
        expect(permissions).to be_empty
      end
    end
  end

  describe '#valid?' do
    before do
      application = Facemock::Application.create!
      user = Facemock::User.create!
      options = { application_id: application.id, user_id: user.id }
      @access_token = Facemock::AccessToken.create!(options)
    end

    subject { @access_token.valid? }
    it { is_expected.to eq true }

    context 'when user_id' do
      context 'is nil' do
        before { @access_token.user_id = nil }
        it { is_expected.to eq false }
      end

      context 'is not Fixnum' do
        before { @access_token.user_id = @access_token.user_id.to_s }
        it { is_expected.to eq false }
      end
    end

    context 'when application_id' do
      context 'is nil' do
        before { @access_token.application_id = nil }
        it { is_expected.to eq false }
      end

      context 'is not Fixnum' do
        before { @access_token.application_id = @access_token.application_id.to_s }
        it { is_expected.to eq false }
      end
    end

    context 'when string' do
      context 'is nil' do
        before { @access_token.string = nil }
        it { is_expected.to eq false }
      end

      context 'is not String' do
        before { @access_token.string = 1 }
        it { is_expected.to eq false }
      end
    end

    context 'when user does not find by user_id' do
      before { @access_token.user.destroy }
      it { is_expected.to eq false }
    end

    context 'when application does not find by application_id' do
      before { @access_token.application.destroy }
      it { is_expected.to eq false }
    end
  end
end
