module GraphAPISpecHelper
  shared_examples 'API 400 Bad Request' do
    it 'should return 400 Bad Request' do
      expect(last_response.status).to eq 400
      header.each{|key, value| expect(last_response.header[key]).to eq value }
      expect(last_response.body).to eq body
    end
  end

  shared_examples 'API 401 Unauthorized' do
    it 'should return 401 Unauthorized' do
      expect(last_response.status).to eq 401
      header.each{|key, value| expect(last_response.header[key]).to eq value }
      expect(last_response.body).to eq body
    end
  end

  shared_examples 'GraphAPI Error' do
    it 'should be equal expected error' do
      expect(error.message).to eq message
      expect(error.type).to eq type
      expect(error.code).to eq code
      expect(error.status).to eq status
    end
  end
end
