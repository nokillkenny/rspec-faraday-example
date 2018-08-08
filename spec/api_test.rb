describe 'zillow GetSearchResults' do
  before(:all) do
    @conn = Faraday.new(url: 'http://www.zillow.com') do |faraday|
      faraday.response :xml, :content_type => /\bxml$/
      faraday.adapter Faraday.default_adapter
    end
  end

  context 'GetSearchResults for 2114 Bigelow Ave Seattle, WA' do
    before(:all) do
      SEARCH_API = '/webservice/GetSearchResults.htm?'
      ZWS_ID = 'zws-id=X1-ZWz1gkvd33djwr_2t4xn'
      ENDPOINT = SEARCH_API + ZWS_ID
    end

    it 'displays house info on success' do
      street = 'address=2114+Bkigelow+Ave'
      citystatezip = 'citystatezip=Seattle+WA'
      address = "#{street}&#{citystatezip}"

      xml_response = @conn.get "#{ENDPOINT}&#{address}"
      puts "Sending request with: #{ENDPOINT}&#{address}"

      actual_text = xml_response.body['searchresults']['message']['text']
      actual_code = xml_response.body['searchresults']['message']['code']

      expect(xml_response.status).to eq 200
      expect(actual_text).to eq 'Request successfully processed'
      expect(actual_code).to eq '0'

      # response matches address info
      actual_address = xml_response.body['searchresults']['response']['results']['result']['address']
      expected_address = {'street' => '2114 Bigelow Ave N', 'zipcode' => '98109', 'city' => 'SEATTLE', 'state' => 'WA', 'latitude' => '47.637934', 'longitude' => '-122.347936'}
      expect(actual_address).to match(expected_address)
    end

    it 'responds with code 2 with invalid ZWSID' do
      street = 'address=2114+Bkigelow+Ave'
      citystatezip = 'citystatezip=Seattle+WA'
      address = "#{street}&#{citystatezip}"

      xml_response = @conn.get "#{SEARCH_API}&#{address}"
      puts "Sending request with: #{SEARCH_API}&#{address}"

      actual_text = xml_response.body['searchresults']['message']['text']
      actual_code = xml_response.body['searchresults']['message']['code']

      expect(xml_response.status).to eq 200
      expect(actual_code).to eq '2'
      expect(actual_text).to eq 'Error: invalid or missing ZWSID parameter'
    end

    it 'responds with code 500 when address is missing' do
      street = ''
      citystatezip = 'citystatezip=Seattle+WA'
      address = "#{street}&#{citystatezip}"

      xml_response = @conn.get "#{ENDPOINT}&#{address}"
      puts "Sending request with: #{ENDPOINT}&#{address}"

      actual_text = xml_response.body['searchresults']['message']['text']
      actual_code = xml_response.body['searchresults']['message']['code']

      expect(xml_response.status).to eq 200
      expect(actual_text).to eq 'Error: no address specified'
      expect(actual_code).to eq '500'
    end

    it 'responds with code 501 when city is missing' do
      street = 'address=2114+Bkigelow+Ave'
      citystatezip = ''
      address = "#{street}&#{citystatezip}"

      xml_response = @conn.get "#{ENDPOINT}&#{address}"
      puts "Sending request with: #{ENDPOINT}&#{address}"

      actual_text = xml_response.body['searchresults']['message']['text']
      actual_code = xml_response.body['searchresults']['message']['code']

      expect(xml_response.status).to eq 200
      expect(actual_text).to eq 'Error: invalid or missing city/state/ZIP parameter'
      expect(actual_code).to eq '501'
    end

    it 'responds with code 508 where address does not exist' do
      street = 'address=2114+Bkigelow+Ave'
      citystatezip = 'citystatezip=Seattle+k'
      address = "#{street}&#{citystatezip}"

      puts "Sending request with: #{ENDPOINT}&#{address}"

      xml_response = @conn.get "#{ENDPOINT}&#{address}"
      actual_text = xml_response.body['searchresults']['message']['text']
      actual_code = xml_response.body['searchresults']['message']['code']

      expect(xml_response.status).to eq 200
      expect(actual_text).to eq 'Error: no exact match found for input address'
      expect(actual_code).to eq '508'
    end
  end
end